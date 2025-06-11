# frozen_string_literal: true

module SolidusPromotions
  module AdjustedAmountByLane
    def adjusted_amount_by_lanes(lanes)
      amount + adjustment_amount_by_lanes(lanes)
    end

    def adjustment_amount_by_lanes(lanes)
      adjustments.select do |adjustment|
        adjustment.promotion? && adjustment.source.promotion.lane.in?(lanes)
      end.sum(&:amount)
    end
  end
end
