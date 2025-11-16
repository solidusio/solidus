# frozen_string_literal: true

module SolidusPromotions
  module Discountable
    def discountable_amount
      amount + previous_lane_discounts.sum(&:amount)
    end

    def current_lane_discounts
      raise NotCalculatingPromotions unless Promotion.current_lane

      discounts_by_lanes([Promotion.current_lane])
    end

    def previous_lane_discounts
      raise NotCalculatingPromotions unless Promotion.current_lane

      discounts_by_lanes(Promotion.lanes_before_current_lane)
    end
  end
end
