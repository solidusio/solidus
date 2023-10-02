# frozen_string_literal: true

module SolidusFriendlyPromotions
  module ShipmentDecorator
    Spree::Shipment.prepend SolidusFriendlyPromotions::DiscountableAmount
  end
end
