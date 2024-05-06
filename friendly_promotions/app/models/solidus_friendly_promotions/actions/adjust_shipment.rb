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

      private

      def possible_conditions
        super + SolidusFriendlyPromotions.config.shipment_rules
      end
    end
  end
end
