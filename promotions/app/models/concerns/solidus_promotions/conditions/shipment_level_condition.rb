# frozen_string_literal: true

module SolidusPromotions
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
