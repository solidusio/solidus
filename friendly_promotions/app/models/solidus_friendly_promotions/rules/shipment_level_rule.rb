# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Rules
    module ShipmentLevelRule
      def applicable?(promotable)
        promotable.is_a?(Spree::Shipment)
      end

      def level
        :shipment
      end
    end
  end
end
