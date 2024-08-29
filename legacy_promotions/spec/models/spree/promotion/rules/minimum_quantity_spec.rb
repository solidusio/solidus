# frozen_string_literal: true

require "rails_helper"

RSpec.describe Spree::Promotion::Rules::MinimumQuantity do
  subject(:quantity_rule) { described_class.new(preferred_minimum_quantity: 2) }

  describe "#valid?" do
    let(:promotion) { build(:promotion) }

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

    let(:order) {
      create(
        :order_with_line_items,
        line_items_count: line_items.length,
        line_items_attributes: line_items
      )
    }
    let(:promotion) { build(:promotion) }

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
      let(:variant_1) { create(:variant) }
      let(:variant_2) { create(:variant) }
      let(:variant_3) { create(:variant) }

      let(:product_rule) {
        Spree::Promotion::Rules::Product.new(
          products: [variant_1.product, variant_2.product],
          preferred_match_policy: "any"
        )
      }

      before { promotion.rules << product_rule }

      context "when the applicable quantity is less than the minimum" do
        let(:line_items) do
          [
            {variant: variant_1, quantity: 1},
            {variant: variant_3, quantity: 1}
          ]
        end

        it { is_expected.to be false }
      end

      context "when the applicable quantity is greater than the minimum" do
        let(:line_items) do
          [
            {variant: variant_1, quantity: 1},
            {variant: variant_2, quantity: 1},
            {variant: variant_3, quantity: 1}
          ]
        end

        it { is_expected.to be true }
      end
    end
  end
end
