# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Conditions
    module ShipmentLevelCondition
      def applicable?(promotable)
        promotable.is_a?(Spree::Shipment)
      end

      def level
        :shipment
      end
    end
  end
end
