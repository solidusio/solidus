# frozen_string_literal: true

module SolidusPromotions
  class OrderAdjuster
    module SetDiscountsToZero
      extend self

      def call(order)
        order.line_items.each do |line_item|
          reset_item_adjustments(line_item)
        end

        order.shipments.each do |shipment|
          reset_item_adjustments(shipment)
          shipment.shipping_rates.each do |shipping_rate|
            reset_shipping_rate_discounts(shipping_rate)
          end
        end
        order
      end

      private

      def reset_item_adjustments(item)
        item.adjustments.select(&:promotion?).each { |adjustment| adjustment.amount = 0 }
      end

      def reset_shipping_rate_discounts(rate)
        rate.discounts.each { |discount| discount.amount = 0 }
      end
    end
  end
end
