# frozen_string_literal: true

module SolidusPromotions
  module Benefits
    module ShipmentBenefit
      def can_discount?(object)
        object.is_a?(Spree::Shipment) || object.is_a?(Spree::ShippingRate)
      end

      def level
        :shipment
      end
    end
  end
end
