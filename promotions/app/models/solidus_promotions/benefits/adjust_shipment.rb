# frozen_string_literal: true

module SolidusPromotions
  module Benefits
    class AdjustShipment < Benefit
      def discount_shipment(shipment, ...)
        adjustment = find_adjustment(shipment) || build_adjustment(shipment)
        adjustment.amount = compute_amount(shipment, ...)
        adjustment.label = adjustment_label(shipment)
        adjustment
      end

      def discount_shipping_rate(shipping_rate, ...)
        discount = find_discount(shipping_rate) || build_discount(shipping_rate)
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

      private

      def find_adjustment(shipment)
        shipment.adjustments.detect do |adjustment|
          adjustment.source == self
        end
      end

      def build_adjustment(shipment)
        shipment.adjustments.build(
          order: shipment.order,
          source: self
        )
      end

      def find_discount(shipping_rate)
        shipping_rate.discounts.detect do |discount|
          discount.benefit == self
        end
      end

      def build_discount(shipping_rate)
         shipping_rate.discounts.build(benefit: self)
      end
    end
  end
end
