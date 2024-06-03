# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Legacy promotion system" do
  describe "promotions with a quantity adjustment" do
    let(:action) { Spree::Promotion::Actions::CreateQuantityAdjustments.create!(calculator: calculator, promotion: promotion) }

    let(:order) do
      create(
        :order_with_line_items,
        line_items_attributes: line_items_attributes
      )
    end

    let(:line_items_attributes) do
      [
        { price: 10, quantity: quantity }
      ]
    end

    let(:quantity) { 1 }
    let(:promotion) { FactoryBot.create :promotion }

    # Regression test for https://github.com/solidusio/solidus/pull/1591
    context "with unsaved line_item changes" do
      let(:calculator) { FactoryBot.create :flat_rate_calculator }
      let(:line_item) { order.line_items.first }

      before do
        order.line_items.first.promo_total = -11
        action.compute_amount(line_item)
      end

      it "doesn't reload the line_items association" do
        expect(order.line_items.first.promo_total).to eq(-11)
      end
    end

    # Regression test for https://github.com/solidusio/solidus/pull/1591
    context "applied to the order" do
      let(:calculator) { FactoryBot.create :flat_rate_calculator }

      before do
        action.perform(order: order, promotion: promotion)
        order.recalculate
      end

      it "updates the order totals" do
        expect(order).to have_attributes(
          total: 100,
          adjustment_total: -10
        )
      end

      context "after updating item quantity" do
        before do
          order.line_items.first.update!(quantity: 2, price: 30)
          order.recalculate
        end

        it "updates the order totals" do
          expect(order).to have_attributes(
            total: 140,
            adjustment_total: -20
          )
        end
      end

      context "after updating promotion amount" do
        before do
          calculator.update!(preferred_amount: 5)
          order.recalculate
        end

        it "updates the order totals" do
          expect(order).to have_attributes(
            total: 105,
            adjustment_total: -5
          )
        end
      end
    end
  end

  describe "distributing amount across line items" do
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
end
