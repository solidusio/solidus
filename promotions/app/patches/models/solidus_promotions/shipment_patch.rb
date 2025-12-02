# frozen_string_literal: true

module SolidusPromotions
  module ShipmentPatch
    Spree::Shipment.prepend SolidusPromotions::DiscountableAmount

    def reset_current_discounts
      super
      shipping_rates.each(&:reset_current_discounts)
    end

    private

    def discounts_by_lanes(lanes)
      adjustments.select do |adjustment|
        !adjustment.marked_for_destruction? &&
          adjustment.source_type == "SolidusPromotions::Benefit" &&
          adjustment.source.promotion.lane.in?(lanes)
      end
    end

    Spree::Shipment.prepend self
    Spree::Shipment.prepend SolidusPromotions::DiscountedAmount
  end
end
