# frozen_string_literal: true

module SolidusPromotions
  module Benefits
    module ShipmentBenefit
      def self.included(_base)
        Spree.deprecator.warn("Including #{name} is deprecated.")
      end

      def can_discount?(object)
        object.is_a?(Spree::Shipment) || object.is_a?(Spree::ShippingRate)
      end

      def level
        :shipment
      end
      deprecate :level, deprecator: Spree.deprecator
    end
  end
end
