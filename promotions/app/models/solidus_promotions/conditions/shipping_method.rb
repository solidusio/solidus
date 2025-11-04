# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    class ShippingMethod < Condition
      # TODO: Remove in Solidus 5
      include ShipmentLevelCondition

      preference :shipping_method_ids, type: :array, default: []

      def shipment_eligible?(promotable, _options = {})
        promotable.shipping_method&.id&.in?(preferred_shipping_method_ids.map(&:to_i))
      end
      alias_method :shipping_rate_eligible?, :shipment_eligible?
    end
  end
end
