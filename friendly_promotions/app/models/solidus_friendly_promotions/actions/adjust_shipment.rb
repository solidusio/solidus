# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Actions
    class AdjustShipment < PromotionAction
      def can_discount?(object)
        object.is_a?(Spree::Shipment) || object.is_a?(Spree::ShippingRate)
      end

      def level
        :shipment
      end
    end
  end
end
