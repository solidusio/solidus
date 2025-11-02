# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::Condition do
  it { is_expected.to belong_to(:benefit) }
  let(:bad_test_condition_class) { Class.new(SolidusPromotions::Condition) }
  let(:test_condition_class) do
    Class.new(SolidusPromotions::Condition) do
      def self.model_name
        ActiveModel::Name.new(self, nil, "test_condition")
      end

      def order_eligible?(_order, _options = {})
        true
      end

      def applicable?(_promotable)
        true
      end

      def level
        :line_item
      end
    end
  end

  let(:benefit) { create(:solidus_promotion, :with_adjustable_benefit).benefits.first }

  describe "preferences" do
    subject { described_class.new.preferences }

    it { is_expected.to be_a(Hash) }
  end

  describe "#preload_relations" do
    let(:condition) { described_class.new }
    subject { condition.preload_relations }

    it { is_expected.to be_empty }
  end

  describe "#eligible?" do
    let(:order_condition) do
      Class.new(described_class) do
        def order_eligible?(_order) = true
      end
    end
    let(:line_item_condition) do
      Class.new(described_class) do
        def line_item_eligible?(_order) = true
      end
    end

    subject { condition.new.eligible?(promotable) }

    context "promotable is order" do
      let(:promotable) { Spree::Order.new }

      context "if condition implements order_eligible?" do
        let(:condition) { order_condition }

        it { is_expected.to be true }
      end

      context "if condition does not implement order_eligible?" do
        context "if condition implements order_eligible?" do
          let(:condition) { line_item_condition }

          it "raises NotImplementedError" do
            expect { subject }.to raise_error(NotImplementedError)
          end
        end
      end
    end

    describe "passing on options to a condition" do
      let(:price_condition) do
        Class.new(described_class) do
          def price_eligible?(_price, options = {})
            options[:order].present? && options[:quantity] > 1
          end
        end
      end

      let(:order) { Spree::Order.new }
      let(:price) { Spree::Price.new }

      subject { price_condition.new.eligible?(price, order:, quantity:) }

      context "with quantity 1" do
        let(:quantity) { 1 }

        it { is_expected.to be false }
      end

      context "with quantity 2" do
        let(:quantity) { 2 }

        it { is_expected.to be true }
      end

      context "if condition does not care about order" do
        let(:price_condition) do
          Class.new(described_class) do
            def price_eligible?(_price, options = {})
              options[:quantity] > 1
            end
          end
        end

        let(:quantity) { 2 }

        it { is_expected.to be true }
      end
    end
  end

  it "forces developer to implement #applicable?" do
    expect { bad_test_condition_class.new.applicable?("promotable") }.to raise_error NotImplementedError
    expect { test_condition_class.new.applicable?("promotable") }.not_to raise_error
  end

  it "forces developer to implement #level", :silence_deprecations do
    expect { bad_test_condition_class.new.level }.to raise_error NotImplementedError
    expect { test_condition_class.new.level }.not_to raise_error
  end

  it "validates unique conditions for a promotion benefit" do
    # Because of Rails' STI, we can't use the anonymous class here
    promotion = create(:solidus_promotion, :with_adjustable_benefit)
    promotion_benefit = promotion.benefits.first
    condition_one = SolidusPromotions::Conditions::FirstOrder.new(benefit: benefit)
    condition_one.benefit_id = promotion_benefit.id
    condition_one.save!

    condition_two = SolidusPromotions::Conditions::FirstOrder.new(benefit: benefit)
    condition_two.benefit_id = promotion_benefit.id
    expect(condition_two).not_to be_valid
    expect(condition_two.errors.full_messages).to include("Benefit already contains this condition type")
  end

  it "generates its own partial path" do
    condition = test_condition_class.new
    expect(condition.to_partial_path).to eq "solidus_promotions/admin/condition_fields/test_condition"
  end
end
