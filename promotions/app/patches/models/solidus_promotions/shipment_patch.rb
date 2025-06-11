# frozen_string_literal: true

module SolidusPromotions
  module ShipmentPatch
    Spree::Shipment.prepend SolidusPromotions::DiscountableAmount

    def reset_current_discounts
      super
      shipping_rates.each(&:reset_current_discounts)
    end

    Spree::Shipment.prepend self
    Spree::Shipment.prepend SolidusPromotions::AdjustedAmountByLane
  end
end
