# frozen_string_literal: true

module SolidusPromotions
  module DiscountedAmount
    def current_lane_discounts
      raise NotCalculatingPromotions unless Promotion.current_lane

      discounts_by_lanes([Promotion.current_lane])
    end

    def previous_lane_discounts
      discounts_by_lanes(Promotion.lanes_before_current_lane)
    end
  end
end
