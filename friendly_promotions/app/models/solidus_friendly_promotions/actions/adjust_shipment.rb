# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Actions
    class AdjustShipment < PromotionAction
      def can_discount?(object)
        object.is_a?(Discountable::Shipment) || object.is_a?(Discountable::ShippingRate)
      end

      def available_calculators
        SolidusFriendlyPromotions.config.shipment_discount_calculators
      end
    end
  end
end
