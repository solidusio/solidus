# frozen_string_literal: true

module SolidusPromotions
  module Benefits
    class AdjustShipment < Benefit
      include SolidusPromotions::Benefits::ShipmentBenefit

      def possible_conditions
        super + SolidusPromotions.config.shipment_conditions
      end
    end
  end
end
