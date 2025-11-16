# frozen_string_literal: true

module SolidusPromotions
  module DiscountableAmount
    def current_discounts
      @current_discounts ||= []
    end
    deprecate current_discounts: :previous_lane_discounts, deprecator: Spree.deprecator

    def current_discounts=(args)
      @current_discounts = args
    end
    deprecate :current_discounts=, deprecator: Spree.deprecator

    def reset_current_discounts
      @current_discounts = []
    end
    deprecate :reset_current_discounts=, deprecator: Spree.deprecator
  end
end
