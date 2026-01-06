# frozen_string_literal: true

require "rails_helper"

RSpec.describe SolidusPromotions::OrderAdjuster::RecalculatePromoTotals do
  describe ".call" do
    let(:promotion) { create(:solidus_promotion, :with_adjustable_benefit) }
    let(:benefit) { promotion.benefits.first }
    let(:order) { create(:order_with_line_items, line_items_count: 2) }
    subject { described_class.call(order) }

    context "with zero-amount adjustments" do
      before do
        order.line_items.first.adjustments.build(
          amount: 0,
          source: benefit
        )
      end

      it "marks zero-amount adjustments for destruction" do
        subject
        expect(order.line_items.first.adjustments.select(&:marked_for_destruction?)).not_to be_empty
      end
    end

    context "with promotional adjustments" do
      before do
        order.line_items.first.adjustments.build(
          amount: -10,
          source: benefit
        )
      end

      it "calculates promo_total for line items" do
        subject
        expect(order.line_items.first.promo_total).to eq(-10)
      end
    end

    context "with shipments" do
      let(:shipment) { create(:shipment, order: order) }

      before do
        shipment.adjustments.build(
          amount: -5,
          source: benefit
        )
      end

      it "calculates promo_total for shipments" do
        subject
        expect(shipment.promo_total).to eq(-5)
      end
    end

    it "returns the order" do
      expect(subject).to eq(order)
    end

    it "updates order item_total and item_count" do
      order.item_total = 0
      order.item_count = 0
      subject
      expect(order.item_total).to be > 0
      expect(order.item_count).to eq(2)
    end
  end
end
