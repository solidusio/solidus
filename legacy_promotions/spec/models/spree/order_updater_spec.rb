# frozen_string_literal: true

require "rails_helper"

module Spree
  RSpec.describe OrderUpdater, type: :model do
    let!(:store) { create :store }
    let(:order) { Spree::Order.create }
    let(:updater) { Spree::OrderUpdater.new(order) }

    context "order totals" do
      before do
        2.times do
          create(:line_item, order:, price: 10)
        end
      end

      context "with order promotion followed by line item addition" do
        let(:promotion) { Spree::Promotion.create!(name: "10% off") }
        let(:calculator) { Calculator::FlatPercentItemTotal.new(preferred_flat_percent: 10) }

        let(:promotion_action) do
          Promotion::Actions::CreateAdjustment.create!({
            calculator:,
            promotion:
          })
        end

        before do
          updater.recalculate
          create(:adjustment, source: promotion_action, adjustable: order, order:)
          create(:line_item, order:, price: 10) # in addition to the two already created
          order.line_items.reload # need to pick up the extra line item
          updater.recalculate
        end

        it "updates promotion total" do
          expect(order.promo_total).to eq(-3)
        end
      end

      it "update order adjustments" do
        create(:adjustment, adjustable: order, order:, source: nil, amount: 10)

        expect {
          updater.recalculate
        }.to change {
          order.adjustment_total
        }.from(0).to(10)
      end
    end

    describe "updating in-memory items" do
      let(:order) do
        create(:order_with_line_items, line_items_count: 1, line_items_price: 10)
      end
      let(:line_item) { order.line_items.first }
      let(:promotion) { create(:promotion, :with_line_item_adjustment, adjustment_rate: 1) }

      it "updates in-memory items" do
        promotion.activate(order:)

        expect(line_item.promo_total).to eq(0)
        expect(order.promo_total).to eq(0)

        order.recalculate

        expect(line_item.promo_total).to eq(-1)
        expect(order.promo_total).to eq(-1)
      end
    end
  end
end
