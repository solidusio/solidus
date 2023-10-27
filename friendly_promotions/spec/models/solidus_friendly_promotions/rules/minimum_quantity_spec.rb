# frozen_string_literal: true

RSpec.describe SolidusFriendlyPromotions::Rules::MinimumQuantity do
  subject(:quantity_rule) { described_class.new(preferred_minimum_quantity: 2) }

  describe "#valid?" do
    let(:promotion) { build(:friendly_promotion) }

    before { promotion.rules << quantity_rule }

    it { is_expected.to be_valid }

    context "when minimum quantity is zero" do
      subject(:quantity_rule) { described_class.new(preferred_minimum_quantity: 0) }

      it { is_expected.not_to be_valid }
    end
  end

  describe "#applicable?" do
    subject { quantity_rule.applicable?(promotable) }

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
    subject { quantity_rule.eligible?(order) }

    let(:order) do
      create(
        :order_with_line_items,
        line_items_count: line_items.length,
        line_items_attributes: line_items
      )
    end
    let(:promotion) { build(:friendly_promotion) }

    before { promotion.rules << quantity_rule }

    context "when only the quantity rule is applied" do
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

    context "when another rule limits the applicable items" do
      let(:carry_on) { create(:variant) }
      let(:other_carry_on) { create(:variant) }
      let(:everywhere_bag) { create(:product).master }

      let(:product_rule) {
        SolidusFriendlyPromotions::Rules::LineItemProduct.new(
          products: [carry_on.product, other_carry_on.product],
          preferred_match_policy: "any"
        )
      }

      before { promotion.rules << product_rule }

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
