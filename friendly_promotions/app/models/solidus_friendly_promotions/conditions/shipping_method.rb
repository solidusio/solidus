# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Conditions
    class ShippingMethod < Condition
      include ShipmentLevelCondition

      preference :shipping_method_ids, type: :array, default: []

      def applicable?(promotable)
        promotable.is_a?(Spree::Shipment) || promotable.is_a?(Spree::ShippingRate)
      end

      def eligible?(promotable)
        promotable.shipping_method&.id&.in?(preferred_shipping_method_ids.map(&:to_i))
      end
    end
  end
end
