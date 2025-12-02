# frozen_string_literal: true

module SolidusPromotions
  module ShipmentPatch
    Spree::Shipment.prepend SolidusPromotions::DiscountableAmount

    def reset_current_discounts
      super
      shipping_rates.each(&:reset_current_discounts)
    end

    def discounted_amount
      amount + previous_lanes_discounts.sum(&:amount)
    end

    private

    def previous_lanes_discounts
      discounts_by_lanes(PromotionLane.previous_lanes)
    end

    def discounts_by_lanes(lanes)
      adjustments.select do |adjustment|
        !adjustment.marked_for_destruction? &&
          adjustment.source_type == "SolidusPromotions::Benefit" &&
          adjustment.source.promotion.lane.in?(lanes)
      end
    end

    Spree::Shipment.prepend self
  end
end
