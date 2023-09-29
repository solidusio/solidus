# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Rules
    class ShippingMethod < PromotionRule
      preference :shipping_method_ids, type: :array, default: []

      def applicable?(promotable)
        promotable.is_a?(Discountable::Shipment) || promotable.is_a?(Discountable::ShippingRate)
      end

      def eligible?(promotable)
        promotable.shipping_method&.id&.in?(preferred_shipping_method_ids.map(&:to_i))
      end

      def updateable?
        true
      end
    end
  end
end
