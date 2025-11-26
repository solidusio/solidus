# frozen_string_literal: true

module SolidusPromotions
  class OrderAdjuster
    class CleanDiscountedOrder
      attr_reader :order

      def initialize(order)
        @order = order
      end

      def call
        order.line_items.each do |line_item|
          line_item.adjustments.select { _1.amount.zero? }.each(&:mark_for_destruction)
        end

        order.shipments.each do |shipment|
          shipment.adjustments.select { _1.amount.zero? }.each(&:mark_for_destruction)
          shipment.shipping_rates.each do |shipping_rate|
            shipping_rate.discounts.select { _1.amount.zero? }.each(&:mark_for_destruction)
          end
        end

        order
      end
    end
  end
end
