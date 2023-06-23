# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Actions
    class AdjustShipment < Base
      def can_adjust?(object)
        object.is_a? Spree::Shipment
      end

      def available_calculators
        SolidusFriendlyPromotions.config.shipment_discount_calculators
      end
    end
  end
end
