# frozen_string_literal: true

module SolidusPromotions
  module Benefits
    class AdjustShipment < Benefit
      def discount_shipment(shipment, ...)
        amount = compute_amount(shipment, ...)
        return if amount.zero?

        ItemDiscount.new(
          item: shipment,
          label: adjustment_label(shipment),
          amount: amount,
          source: self
        )
      end

      def discount_shipping_rate(shipping_rate, ...)
        amount = compute_amount(shipping_rate, ...)
        return if amount.zero?

        ItemDiscount.new(
          item: shipping_rate,
          label: adjustment_label(shipping_rate),
          amount: amount,
          source: self
        )
      end

      def possible_conditions
        super + SolidusPromotions.config.shipment_conditions
      end

      def level
        :shipment
      end
      deprecate :level, deprecator: Spree.deprecator
    end
  end
end
