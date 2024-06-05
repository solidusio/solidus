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

  describe "completing multiple orders with the same code", slow: true do
    let(:promotion) do
      FactoryBot.create(
        :promotion,
        :with_order_adjustment,
        code: "discount",
        per_code_usage_limit: 1,
        weighted_order_adjustment_amount: 10
      )
    end
    let(:code) { promotion.codes.first }
    let(:order) do
      FactoryBot.create(:order_with_line_items, line_items_price: 40, shipment_cost: 0).tap do |order|
        FactoryBot.create(:payment, amount: 30, order: order)
        promotion.activate(order: order, promotion_code: code)
      end
    end
    let(:promo_adjustment) { order.adjustments.promotion.first }
    before do
      order.next! until order.can_complete?

      FactoryBot.create(:order_with_line_items, line_items_price: 40, shipment_cost: 0).tap do |order|
        FactoryBot.create(:payment, amount: 30, order: order)
        promotion.activate(order: order, promotion_code: code)
        order.next! until order.can_complete?
        order.complete!
      end
    end

    it "makes the promotion ineligible" do
      expect{
        order.complete
      }.to change{ promo_adjustment.reload.eligible }.to(false)
    end

    it "adjusts the promo_total" do
      expect{
        order.complete
      }.to change(order, :promo_total).by(10)
    end

    it "increases the total to remove the promo" do
      expect{
        order.complete
      }.to change(order, :total).from(30).to(40)
    end

    it "resets the state of the order" do
      expect{
        order.complete
      }.to change{ order.reload.state }.from("confirm").to("address")
    end
  end

  describe "adding items to the cart" do
    let(:order) { create :order }
    let(:line_item) { create :line_item, order: order }
    let(:promo) { create :promotion_with_item_adjustment, adjustment_rate: 5, code: 'promo' }
    let(:promotion_code) { promo.codes.first }
    let(:variant) { create :variant }

    it "updates the promotions for new line items" do
      expect(line_item.adjustments).to be_empty
      expect(order.adjustment_total).to eq 0

      promo.activate order: order, promotion_code: promotion_code
      order.recalculate

      expect(line_item.adjustments.size).to eq(1)
      expect(order.adjustment_total).to eq(-5)

      other_line_item = order.contents.add(variant, 1, currency: order.currency)

      expect(other_line_item).not_to eq line_item
      expect(other_line_item.adjustments.size).to eq(1)
      expect(order.adjustment_total).to eq(-10)
    end
  end
end
