# frozen_string_literal: true

module SolidusPromotions
  class OrderAdjuster
    module RecalculatePromoTotals
      extend self

      def call(order)
        order.line_items.each do |line_item|
          line_item.adjustments.select { _1.amount.zero? }.each(&:mark_for_destruction)

          line_item.promo_total = calculate_promo_total_for_adjustable(line_item)
        end

        order.shipments.each do |shipment|
          shipment.adjustments.select { _1.amount.zero? }.each(&:mark_for_destruction)
          shipment.shipping_rates.each do |shipping_rate|
            shipping_rate.discounts.select { _1.amount.zero? }.each(&:mark_for_destruction)
          end

          shipment.promo_total = calculate_promo_total_for_adjustable(shipment)
        end

        line_items = order.line_items.reject(&:marked_for_destruction?)
        order.item_total = line_items.sum(&:amount)
        order.item_count = line_items.sum(&:quantity)

        order.promo_total = (line_items + order.shipments.reject(&:marked_for_destruction?)).sum(&:promo_total)

        order.adjustment_total = order.promo_total
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
