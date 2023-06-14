# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Actions
    class AdjustShipment < Base
      class_attribute :available_calculators, default: []

      def can_adjust?(object)
        object.is_a? Spree::Shipment
      end
    end
  end
end
