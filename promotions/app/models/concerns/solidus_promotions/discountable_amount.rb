# frozen_string_literal: true

module SolidusPromotions
  module DiscountableAmount
    def discountable_amount
      amount + current_discounts.sum(&:amount)
    end

    def current_discounts
      @current_discounts ||= []
    end

    def current_discounts=(args)
      @current_discounts = args
    end

    def current_lane_discounts
      @current_lane_discounts ||= []
    end

    def current_lane_discounts=(args)
      @current_lane_discounts = args
    end

    def reset_current_discounts
      @current_discounts = []
    end
  end
end
