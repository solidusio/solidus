# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Legacy promotion system" do
  describe "promotions with a quantity adjustment" do
    let(:action) { Spree::Promotion::Actions::CreateQuantityAdjustments.create!(calculator:, promotion:) }

    let(:order) do
      create(
        :order_with_line_items,
        line_items_attributes:
      )
    end

    let(:line_items_attributes) do
      [
        { price: 10, quantity: }
      ]
    end

    let(:quantity) { 1 }
    let(:promotion) { FactoryBot.create :promotion }

    # Regression test for https://github.com/solidusio/solidus/pull/1591
    context "with unsaved line_item changes" do
      let(:calculator) { FactoryBot.create(:flat_rate_calculator) }
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
        action.perform(order:, promotion:)
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

      context "with the in-memory order updater" do
        subject { order.recalculate(persist: false) }

        before {
          calculator.update!(preferred_amount: 5)
        }

        around do |example|
          default_order_recalculator = Spree::Config.order_recalculator_class.to_s

          Spree::Config.order_recalculator_class = 'Spree::InMemoryOrderUpdater'

          example.run

          Spree::Config.order_recalculator_class = default_order_recalculator
        end

        it "updates the adjustment total but does not persist it" do
          expect(order.adjustment_total).to eq(-10.0)

          expect { subject }.
            to_not make_database_queries(manipulative: true)

          expect(order).to have_attributes(
            total: 105,
            adjustment_total: -5
          )

          order.reload

          expect(order.adjustment_total).to eq(-10)
        end
      end
    end
  end

  describe "distributing amount across line items" do
    subject { order.recalculate }

    let(:calculator) { Spree::Calculator::DistributedAmount.new(preferred_amount: 15) }
    let(:promotion) {
      create :promotion,
        name: '15 spread'
    }

    before {
      Spree::Promotion::Actions::CreateItemAdjustments.create!(calculator:, promotion:)
    }

    let!(:order) {
      create :completed_order_with_promotion,
        promotion:,
        line_items_attributes: [{ price: 20 }, { price: 30 }, { price: 100 }]
    }

    it 'correctly distributes the entire discount', :aggregate_failures do
      subject

      expect(order.promo_total).to eq(-15)
      expect(order.line_items.map(&:adjustment_total)).to eq([-2, -3, -10])
    end

    context 'with the in memory order updater' do
      subject { order.recalculate(persist: false) }

      around do |example|
        default_order_recalculator = Spree::Config.order_recalculator_class.to_s

        Spree::Config.order_recalculator_class = 'Spree::InMemoryOrderUpdater'

        example.run

        Spree::Config.order_recalculator_class = default_order_recalculator
      end

      it 'initializes the adjustments but does not persist them' do
        expect {
          subject
        }.not_to make_database_queries(manipulative: true)

        expect(order.promo_total).to eq(-15)
        expect(order.line_items.map(&:adjustment_total)).to eq([-2, -3, -10])

        order.reload

        expect(order.promo_total).to eq(0)
        expect(order.line_items.map(&:adjustment_total)).to eq([0, 0, 0])
      end
    end

    context 'with product promotion rule' do
      subject { order.recalculate }

      let(:first_product) { order.line_items.first.product }

      before do
        calculator.preferred_amount = 15
        Spree::Promotion::Actions::CreateItemAdjustments.create!(calculator:, promotion:)
        rule = Spree::Promotion::Rules::Product.create!(
          promotion:,
          product_promotion_rules: [
            Spree::ProductPromotionRule.new(product: first_product),
          ],
        )
        promotion.rules << rule
        promotion.save!
      end

      it 'still distributes the entire discount' do
        subject

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
        FactoryBot.create(:payment, amount: 30, order:)
        promotion.activate(order:, promotion_code: code)
      end
    end
    let(:promo_adjustment) { order.adjustments.promotion.first }
    before do
      order.next! until order.can_complete?

      FactoryBot.create(:order_with_line_items, line_items_price: 40, shipment_cost: 0).tap do |order|
        FactoryBot.create(:payment, amount: 30, order:)
        promotion.activate(order:, promotion_code: code)
        order.next! until order.can_complete?
        order.complete!
      end
    end

    it "makes the promotion ineligible" do
      expect{
        order.complete
      }.to change{ promo_adjustment.reload.eligible }.to(false)
    end
  end

  describe "checking whether a promotion code is still eligible after one use" do
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
        FactoryBot.create(:payment, amount: 30, order:)
        promotion.activate(order:, promotion_code: code)
      end
    end
    let(:promo_adjustment) { order.adjustments.promotion.first }

    before do
      order.next! until order.can_complete?

      FactoryBot.create(:order_with_line_items, line_items_price: 40, shipment_cost: 0).tap do |order|
        FactoryBot.create(:payment, amount: 30, order:)
        promotion.activate(order:, promotion_code: code)
        order.next! until order.can_complete?
        order.complete!
      end
    end

    context 'with the in-memory order updater' do
      subject { order.recalculate(persist:) }

      around do |example|
        default_order_recalculator = Spree::Config.order_recalculator_class.to_s

        Spree::Config.order_recalculator_class = Spree::InMemoryOrderUpdater

        example.run

        Spree::Config.order_recalculator_class = default_order_recalculator
      end

      context "when not persisting updates" do
        let(:persist) { false }

        it "doesn't manipulate the database" do
          expect { subject }.not_to make_database_queries(manipulative: true)
        end

        it "changes but does not persist the promotion as ineligible" do
          expect { subject }
            .to change { order.adjustments.first.eligible }
            .from(true)
            .to(false)
        end

        it "changes but does not persist the promo_total" do
          expect { subject }.to change { order.promo_total }.from(-10).to(0)
        end

        it "changes the total but does not persist the promo amount" do
          expect { subject }.to change { order.total }.from(30).to(40)
        end
      end

      context "when persisting updates" do
        let(:persist) { true }

        it "makes the promotion ineligible" do
          expect { subject }
            .to change { promo_adjustment.reload.eligible }
            .from(true)
            .to(false)
        end

        it "adjusts the promo_total" do
          expect { subject }.to change { order.reload.promo_total }.from(-10).to(0)
        end

        it "increases the total to remove the promo" do
          expect { subject }.to change { order.reload.total }.from(30).to(40)
        end

        context "with an item adjustment" do
          let(:promotion) do
            FactoryBot.create(
              :promotion_with_item_adjustment,
              code: "discount",
              per_code_usage_limit: 1,
              adjustment_rate: 10
            )
          end

          it "adjusts the adjustment total" do
            expect { subject }.to change { order.line_items.first.reload.adjustment_total }.from(-10).to(0)
          end
        end
      end
    end
  end

  describe "adding items to the cart" do
    let(:order) { create :order }
    let(:line_item) { create :line_item, order: }
    let(:promo) { create :promotion_with_item_adjustment, adjustment_rate: 5, code: 'promo' }
    let(:promotion_code) { promo.codes.first }
    let(:variant) { create :variant }

    it "updates the promotions for new line items" do
      expect(line_item.adjustments).to be_empty
      expect(order.adjustment_total).to eq 0

      promo.activate(order:, promotion_code:)
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
