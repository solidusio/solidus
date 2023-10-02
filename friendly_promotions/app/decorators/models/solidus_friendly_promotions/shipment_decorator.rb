# frozen_string_literal: true

module SolidusFriendlyPromotions
  module ShipmentDecorator
    Spree::Shipment.prepend SolidusFriendlyPromotions::DiscountableAmount

    def reset_current_discounts
      super
      shipping_rates.each(&:reset_current_discounts)
    end

    Spree::Shipment.prepend self
  end
end
