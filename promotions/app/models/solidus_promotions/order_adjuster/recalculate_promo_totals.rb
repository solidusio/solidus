# frozen_string_literal: true

module SolidusPromotions
  class OrderAdjuster
    class RecalculatePromoTotals
      attr_reader :order

      def initialize(order)
        @order = order
      end

      def call
        order.line_items.each do |line_item|
          line_item.promo_total = calculate_promo_total_for_adjustable(line_item)
        end

        order.shipments.each do |shipment|
          shipment.promo_total = calculate_promo_total_for_adjustable(shipment)
        end

        order.item_total = order.line_items.sum(&:amount)
        order.item_count = order.line_items.sum(&:quantity)
        order.promo_total = (order.line_items + order.shipments).sum(&:promo_total)

        order
      end

      private

      def calculate_promo_total_for_adjustable(adjustable)
        adjustable
          .adjustments
          .select(&:promotion?)
          .reject(&:marked_for_destruction?)
          .sum(&:amount)
      end
    end
  end
end
