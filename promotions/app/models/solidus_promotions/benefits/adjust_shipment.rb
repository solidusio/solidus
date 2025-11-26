# frozen_string_literal: true

module SolidusPromotions
  module Benefits
    class AdjustShipment < Benefit
      def discount_shipment(shipment, ...)
        adjustment = shipment.adjustments.detect do |adjustment|
          adjustment.source == self
        end || shipment.adjustments.build(
          order: shipment.order,
          source: self
        )
        adjustment.amount = compute_amount(shipment, ...)
        adjustment.label = adjustment_label(shipment)
        adjustment
      end

      def discount_shipping_rate(shipping_rate, ...)
        discount = shipping_rate.discounts.detect do |discount|
          discount.benefit == self
        end || shipping_rate.discounts.build(benefit: self)
        discount.amount = compute_amount(shipping_rate, ...)
        discount.label = adjustment_label(shipping_rate)
        discount
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
