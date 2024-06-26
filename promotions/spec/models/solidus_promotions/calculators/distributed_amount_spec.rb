# frozen_string_literal: true

require "rails_helper"
require "shared_examples/calculator_shared_examples"

RSpec.describe SolidusPromotions::Calculators::DistributedAmount, type: :model do
  let(:calculator) { described_class.new(preferred_amount: 15, preferred_currency: currency) }
  let!(:promotion) do
    create :friendly_promotion, apply_automatically: true, name: "15 spread", benefits: [benefit]
  end
  let(:conditions) { [] }
  let(:benefit) { SolidusPromotions::Benefits::AdjustLineItem.create(calculator: calculator, conditions: conditions) }
  let(:order) { create(:order_with_line_items, line_items_attributes: line_items_attributes) }
  let(:currency) { "USD" }

  context "applied to an order" do
    let(:line_items_attributes) { [{ price: 20 }, { price: 30 }, { price: 100 }] }

    before do
      order.recalculate
    end

    it "correctly distributes the entire discount" do
      expect(order.promo_total).to eq(-15)
      expect(order.line_items.map(&:adjustment_total)).to eq([-2, -3, -10])
    end

    context "with product promotion condition" do
      let(:first_product) { order.line_items.first.product }
      let(:conditions) do
        [
          SolidusPromotions::Conditions::LineItemProduct.new(products: [first_product])
        ]
      end

      before do
        order.recalculate
      end

      it "still distributes the entire discount" do
        expect(order.promo_total).to eq(-15)
        expect(order.line_items.map(&:adjustment_total)).to eq([-15, 0, 0])
      end
    end
  end

  describe "#compute_line_item" do
    subject { calculator.compute_line_item(order.line_items.first) }

    let(:line_items_attributes) { [{ price: 50 }, { price: 50 }, { price: 50 }] }

    context "when the order currency matches the store's currency" do
      let(:currency) { "USD" }

      it { is_expected.to eq 5 }
      it { is_expected.to be_a BigDecimal }
    end

    context "when the order currency does not match the store's currency" do
      let(:currency) { "CAD" }

      it { is_expected.to eq 0 }
    end
  end
end
