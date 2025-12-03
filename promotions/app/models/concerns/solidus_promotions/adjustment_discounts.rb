# frozen_string_literal: true

module SolidusPromotions
  module AdjustmentDiscounts
    private

    # Returns adjustments from specified promotion lanes.
    #
    # @param lanes [Array<String>] the promotion lanes to filter by
    # @return [Array<Spree::Adjustment>] promotions adjustments from the
    #   specified lanes that are not marked for destruction
    def discounts_by_lanes(lanes)
      adjustments.select do |adjustment|
        !adjustment.marked_for_destruction? &&
          adjustment.source_type == "SolidusPromotions::Benefit" &&
          adjustment.source.promotion.lane.in?(lanes)
      end
    end
  end
end
