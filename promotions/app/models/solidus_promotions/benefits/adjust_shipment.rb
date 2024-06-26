# frozen_string_literal: true

module SolidusPromotions
  module Benefits
    class AdjustShipment < Benefit
      def can_discount?(object)
        object.is_a?(Spree::Shipment) || object.is_a?(Spree::ShippingRate)
      end

      def level
        :shipment
      end

      def possible_conditions
        super + SolidusPromotions.config.shipment_conditions
      end
    end
  end
end
