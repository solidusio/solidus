# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Benefit do
  it { is_expected.to belong_to(:promotion) }
  it { is_expected.to have_one(:calculator) }
  it { is_expected.to have_many(:shipping_rate_discounts) }
  it { is_expected.to have_many(:conditions) }

  it { is_expected.to respond_to :discount }
  it { is_expected.to respond_to :can_discount? }

  describe "#can_adjust?" do
    let(:adjustable) { Spree::LineItem.new }
    let(:benefit_class) do
      Class.new(described_class) do
        def discount_line_item(line_item, options = {})
        end
      end
    end

    subject { benefit_class.new.can_discount?(adjustable) }

    it { is_expected.to be true }

    context "if passing in an incompatible object" do
      let(:adjustable) { Spree::Shipment.new }

      it { is_expected.to be false }
    end
  end

  describe "#destroy" do
    subject { benefit.destroy }
    let(:benefit) { promotion.benefits.first }
    let!(:promotion) { create(:solidus_promotion, :with_adjustable_benefit, apply_automatically: true) }

    it "destroys the benefit" do
      expect { subject }.to change { SolidusPromotions::Benefit.count }.by(-1)
    end

    context "when the benefit has adjustments on an incomplete order" do
      let(:order) { create(:order_with_line_items) }

      before do
        order.recalculate
      end

      it "destroys the benefit" do
        expect { subject }.to change { SolidusPromotions::Benefit.count }.by(-1)
      end

      it "destroys the adjustments" do
        expect { subject }.to change { Spree::Adjustment.count }.by(-1)
      end

      context "when the benefit has adjustments on a complete order" do
        let(:order) { create(:order_ready_to_complete) }

        before do
          order.recalculate
          order.complete!
        end

        it "raises an error" do
          expect { subject }.not_to change { SolidusPromotions::Benefit.count }
          expect(benefit.errors.full_messages).to include("Benefit has been applied to complete orders. It cannot be destroyed.")
        end
      end
    end
  end

  describe "#preload_relations" do
    let(:benefit) { described_class.new }
    subject { benefit.preload_relations }

    it { is_expected.to eq([:calculator]) }
  end

  describe "#discount" do
    subject { benefit.discount(discountable) }

    let(:benefit_class) do
      Class.new(described_class) do
        def discount_line_item(line_item, options = {})
        end
      end
    end

    let(:variant) { create(:variant) }
    let(:order) { create(:order) }
    let(:discountable) { Spree::LineItem.new(order: order, variant: variant, price: 10, quantity: 1) }
    let(:promotion) { SolidusPromotions::Promotion.new(customer_label: "20 Perzent off") }
    let(:calculator) { SolidusPromotions::Calculators::Percent.new(preferred_percent: 20) }
    let(:benefit) { benefit_class.new(promotion: promotion, calculator: calculator) }

    it "passes adjustable to discount_line_item" do
      expect(benefit).to receive(:discount_line_item).with(discountable)
      subject
    end

    context "if the calculator returns nil" do
      before do
        allow(calculator).to receive(:compute).and_return(nil)
      end

      it "returns nil" do
        expect(subject).to be nil
      end
    end

    context "if the calculator returns zero" do
      let(:calculator) { SolidusPromotions::Calculators::Percent.new(preferred_percent: 0) }

      it "returns nil" do
        expect(subject).to be nil
      end
    end

    context "if discount method for the discountable is not implemented" do
      let(:benefit) { described_class.new }

      it "raises NotImplementError" do
        expect { subject }.to raise_exception(NotImplementedError, "Please implement discount_line_item in your condition")
      end
    end

    context "if passing in extra options" do
      let(:benefit_class) { SolidusPromotions::Benefits::AdjustLineItem }
      let(:calculator_class) do
        Class.new(Spree::Calculator) do
          def compute_line_item(_line_item, _options) = 1
        end
      end
      let(:calculator) { calculator_class.new }
      let(:promotion) { build(:solidus_promotion) }
      let(:benefit) { benefit_class.new(promotion:, calculator:) }
      let(:order) { Spree::Order.new }
      let(:discountable) { build(:line_item, order:) }

      subject { benefit.discount(discountable, extra_data: "foo") }

      it "passes the option on to the calculator" do
        expect(calculator).to receive(:compute_line_item).with(discountable, extra_data: "foo").and_return(1)
        subject
      end
    end
  end

  describe "#compute_amount" do
    subject { benefit.compute_amount(discountable) }

    let(:variant) { create(:variant) }
    let(:order) { create(:order) }
    let(:discountable) { Spree::LineItem.new(order: order, variant: variant, price: 10, quantity: 1) }
    let(:promotion) { SolidusPromotions::Promotion.new(customer_label: "20 Perzent off") }
    let(:calculator) { SolidusPromotions::Calculators::Percent.new(preferred_percent: 20) }
    let(:benefit) { described_class.new(promotion: promotion, calculator: calculator) }

    it "doesn't save anything to the database" do
      discountable

      expect {
        subject
      }.not_to make_database_queries(manipulative: true)
    end
  end

  describe "inherited hook" do
    context "for a well-formed benefit" do
      subject(:benefit) do
        Class.new(described_class) do
          def discount_line_item(_line_item, _options = {})
            true
          end
        end
      end

      it "does not emit a deprecation warning" do
        expect(Spree.deprecator).not_to receive(:warn)
        benefit
      end
    end

    context "for a legacy benefit" do
      subject(:benefit) do
        Class.new(described_class) do
          def self.name
            "LegacyBenefit"
          end

          def discount(_line_item, _options = {})
            true
          end
        end
      end

      it "emits a deprecation warning" do
        expect(Spree.deprecator).to receive(:warn).with(<<~MSG)
          Please refactor `LegacyBenefit`. You're defining `#discount`. Instead, define a method for each type of discountable
          that your benefit can discount. For example:
          ```
          class MyBenefit < SolidusPromotions::Benefit
            def can_discount?(discountable)
              discountable.is_a?(Spree::LineItem)
            end

            def discount(order, _options = {})
              amount = compute_amount(line_item, ...)
              return if amount.zero?

              ItemDiscount.new(
                item: line_item,
                label: adjustment_label(line_item),
                amount: amount,
                source: self
              )
            end
          ```
          can now become
          ```
          class MyBenefit < SolidusPromotions::Benefit
            def discount_line_item(order, ...)
              amount = compute_amount(line_item, ...)
              return if amount.zero?

              ItemDiscount.new(
                item: line_item,
                label: adjustment_label(line_item),
                amount: amount,
                source: self
              )
            end
          end
          ```
        MSG
        benefit
      end
    end
  end

  describe ".original_promotion_action" do
    let(:spree_promotion) { create :promotion, :with_adjustable_action }
    let(:spree_promotion_action) { spree_promotion.actions.first }
    let(:solidus_promotion) { create :solidus_promotion, :with_adjustable_benefit }
    let(:solidus_promotion_benefit) { solidus_promotion.benefits.first }

    subject { solidus_promotion_benefit.original_promotion_action }

    it "can be migrated from spree" do
      solidus_promotion_benefit.original_promotion_action = spree_promotion_action
      expect(subject).to eq(spree_promotion_action)
    end

    it "is ok to be new" do
      expect(subject).to be_nil
    end
  end

  describe "#level", :silence_deprecations do
    subject { described_class.new.level }

    it "raises an error" do
      expect { subject }.to raise_exception(NotImplementedError)
    end
  end

  describe "#adjustment_label" do
    let(:benefit_class) do
      Class.new(described_class) do
      end
    end

    let(:calculator_class) do
      Class.new(Spree::Calculator) do
        include SolidusPromotions::Calculators::PromotionCalculator
      end
    end

    let(:calculator) { calculator_class.new }

    let(:promotion) { build_stubbed(:solidus_promotion, customer_label: "Winter Sale") }

    let(:benefit) { benefit_class.new(calculator:, promotion:) }
    let(:adjustable) { Spree::LineItem.new }

    subject { benefit.adjustment_label(adjustable) }

    it { is_expected.to eq("Promotion (Winter Sale)") }

    context "if the calculator implements #line_item_adjustment_label" do
      let(:calculator_class) do
        Class.new(Spree::Calculator) do
          include SolidusPromotions::Calculators::PromotionCalculator

          def line_item_adjustment_label(_line_item, _options = {})
            "Something entirely different"
          end
        end
      end

      it { is_expected.to eq("Something entirely different") }
    end
  end
end
