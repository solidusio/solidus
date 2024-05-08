# frozen_string_literal: true

RSpec.describe SolidusFriendlyPromotions::Conditions::MinimumQuantity do
  let(:action) { SolidusFriendlyPromotions::Actions::AdjustLineItem.new }
  subject(:quantity_condition) { described_class.new(preferred_minimum_quantity: 2, action: action) }

  describe "#valid?" do
    before { action.conditions << quantity_condition }

    it { is_expected.to be_valid }

    context "when minimum quantity is zero" do
      subject(:quantity_condition) { described_class.new(preferred_minimum_quantity: 0) }

      it { is_expected.not_to be_valid }
    end
  end

  describe "#applicable?" do
    subject { quantity_condition.applicable?(promotable) }

    context "when promotable is an order" do
      let(:promotable) { Spree::Order.new }

      it { is_expected.to be true }
    end

    context "when promotable is a line item" do
      let(:promotable) { Spree::LineItem.new }

      it { is_expected.to be false }
    end
  end

  describe "#eligible?" do
    subject { quantity_condition.eligible?(order) }

    let(:order) do
      create(
        :order_with_line_items,
        line_items_count: line_items.length,
        line_items_attributes: line_items
      )
    end
    let(:action) { SolidusFriendlyPromotions::Actions::AdjustLineItem.new }

    before { action.conditions << quantity_condition }

    context "when only the quantity condition is applied" do
      context "when the quantity is less than the minimum" do
        let(:line_items) { [{quantity: 1}] }

        it { is_expected.to be false }
      end

      context "when the quantity is equal to the minimum" do
        let(:line_items) { [{quantity: 2}] }

        it { is_expected.to be true }
      end

      context "when the quantity is greater than the minimum" do
        let(:line_items) { [{quantity: 4}] }

        it { is_expected.to be true }
      end
    end

    context "when another condition limits the applicable items" do
      let(:carry_on) { create(:variant) }
      let(:other_carry_on) { create(:variant) }
      let(:everywhere_bag) { create(:product).master }

      let(:product_condition) {
        SolidusFriendlyPromotions::Conditions::LineItemProduct.new(
          products: [carry_on.product, other_carry_on.product],
          preferred_match_policy: "any"
        )
      }

      before { action.conditions << product_condition }

      context "when the applicable quantity is less than the minimum" do
        let(:line_items) do
          [
            {variant: carry_on, quantity: 1},
            {variant: everywhere_bag, quantity: 1}
          ]
        end

        it { is_expected.to be false }
      end

      context "when the applicable quantity is greater than the minimum" do
        let(:line_items) do
          [
            {variant: carry_on, quantity: 1},
            {variant: other_carry_on, quantity: 1},
            {variant: everywhere_bag, quantity: 1}
          ]
        end

        it { is_expected.to be true }
      end
    end
  end
end
