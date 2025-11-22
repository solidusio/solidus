# frozen_string_literal: true

module SolidusPromotions
  module AdjustmentDiscounts
    def discounts_by_lanes(lanes)
      adjustments.select do |adjustment|
        adjustment.source_type == "SolidusPromotions::Benefit" &&
          adjustment.source.promotion.lane.to_sym.in?(lanes.map(&:to_sym))
      end
    end
  end
end
