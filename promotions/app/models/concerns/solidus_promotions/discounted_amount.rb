# frozen_string_literal: true

module SolidusPromotions
  module DiscountedAmount
    def discounted_amount
      amount + previous_lane_discounts.sum(&:amount)
    end

    def current_lane_discounts
      raise NotCalculatingPromotions unless PromotionLane.current

      discounts_by_lanes([PromotionLane.current])
    end

    private

    def previous_lane_discounts
      discounts_by_lanes(PromotionLane.before_current)
    end
  end
end
