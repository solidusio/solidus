# frozen_string_literal: true

require 'rails_helper'
require 'shared_examples/calculator_shared_examples'

RSpec.describe Spree::Calculator::DistributedAmount, type: :model do
  context 'applied to an order' do
    let(:calculator) { Spree::Calculator::DistributedAmount.new }
    let(:promotion) {
      create :promotion,
        name: '15 spread'
    }
    let(:order) {
      create :completed_order_with_promotion,
        promotion: promotion,
        line_items_attributes: [{ price: 20 }, { price: 30 }, { price: 100 }]
    }

    before do
      calculator.preferred_amount = 15
      Spree::Promotion::Actions::CreateItemAdjustments.create!(calculator: calculator, promotion: promotion)
      order.recalculate
    end

    it 'correctly distributes the entire discount' do
      expect(order.promo_total).to eq(-15)
      expect(order.line_items.map(&:adjustment_total)).to eq([-2, -3, -10])
    end

    context 'with product promotion rule' do
      let(:first_product) { order.line_items.first.product }

      before do
        rule = Spree::Promotion::Rules::Product.create!(
          promotion: promotion,
          product_promotion_rules: [
            Spree::ProductPromotionRule.new(product: first_product),
          ],
        )
        promotion.rules << rule
        promotion.save!
        order.recalculate
      end

      it 'still distributes the entire discount' do
        expect(order.promo_total).to eq(-15)
        expect(order.line_items.map(&:adjustment_total)).to eq([-15, 0, 0])
      end
    end
  end

  describe "#compute_line_item" do
    subject { calculator.compute_line_item(order.line_items.first) }

    let(:calculator) { Spree::Calculator::DistributedAmount.new }
    let(:promotion) { create(:promotion) }

    let(:order) do
      FactoryBot.create(
        :order_with_line_items,
        line_items_attributes: [{ price: 50 }, { price: 50 }, { price: 50 }]
      )
    end

    before do
      calculator.preferred_amount = 15
      calculator.preferred_currency = currency
      Spree::Promotion::Actions::CreateItemAdjustments.create!(calculator: calculator, promotion: promotion)
    end

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
