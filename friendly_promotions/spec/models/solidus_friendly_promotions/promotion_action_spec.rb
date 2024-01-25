# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusFriendlyPromotions::PromotionAction do
  it { is_expected.to belong_to(:promotion) }
  it { is_expected.to have_one(:calculator) }

  it { is_expected.to respond_to :discount }
  it { is_expected.to respond_to :can_discount? }

  describe "#can_adjust?" do
    subject { described_class.new.can_discount?(double) }

    it "raises a NotImplementedError" do
      expect { subject }.to raise_exception(NotImplementedError)
    end
  end

  describe "#destroy" do
    subject { action.destroy }
    let(:action) { promotion.actions.first }
    let!(:promotion) { create(:friendly_promotion, :with_adjustable_action, apply_automatically: true) }

    it "destroys the action" do
      expect { subject }.to change { SolidusFriendlyPromotions::PromotionAction.count }.by(-1)
    end

    context "when the action has adjustments on an incomplete order" do
      let(:order) { create(:order_with_line_items) }

      before do
        order.recalculate
      end

      it "destroys the action" do
        expect { subject }.to change { SolidusFriendlyPromotions::PromotionAction.count }.by(-1)
      end

      it "destroys the adjustments" do
        expect { subject }.to change { Spree::Adjustment.count }.by(-1)
      end

      context "when the action has adjustments on a complete order" do
        let(:order) { create(:order_ready_to_complete) }

        before do
          order.recalculate
          order.complete!
        end

        it "raises an error" do
          expect { subject }.not_to change { SolidusFriendlyPromotions::PromotionAction.count }
          expect(action.errors.full_messages).to include("Action has been applied to complete orders. It cannot be destroyed.")
        end
      end
    end
  end

  describe "#discount" do
    subject { action.discount(discountable) }

    let(:variant) { create(:variant) }
    let(:order) { create(:order) }
    let(:discountable) { Spree::LineItem.new(order: order, variant: variant, price: 10, quantity: 1) }
    let(:promotion) { SolidusFriendlyPromotions::Promotion.new(customer_label: "20 Perzent off") }
    let(:calculator) { SolidusFriendlyPromotions::Calculators::Percent.new(preferred_percent: 20) }
    let(:action) { described_class.new(promotion: promotion, calculator: calculator) }

    it "returns an discount to the discountable" do
      expect(subject).to eq(
        SolidusFriendlyPromotions::ItemDiscount.new(
          item: discountable,
          label: "Promotion (20 Perzent off)",
          source: action,
          amount: -2
        )
      )
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
      let(:calculator) { SolidusFriendlyPromotions::Calculators::Percent.new(preferred_percent: 0) }

      it "returns nil" do
        expect(subject).to be nil
      end
    end
  end

  describe ".original_promotion_action" do
    let(:spree_promotion) { create :promotion, :with_adjustable_action }
    let(:spree_promotion_action) { spree_promotion.actions.first }
    let(:friendly_promotion) { create :friendly_promotion, :with_adjustable_action }
    let(:friendly_promotion_action) { friendly_promotion.actions.first }

    subject { friendly_promotion_action.original_promotion_action }

    it "can be migrated from spree" do
      friendly_promotion_action.original_promotion_action = spree_promotion_action
      expect(subject).to eq(spree_promotion_action)
    end

    it "is ok to be new" do
      expect(subject).to be_nil
    end
  end

  describe "#level" do
    subject { described_class.new.level }

    it "raises an error" do
      expect { subject }.to raise_exception(NotImplementedError)
    end
  end
end
