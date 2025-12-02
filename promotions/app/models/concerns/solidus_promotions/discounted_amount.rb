# frozen_string_literal: true

module SolidusPromotions
  module DiscountedAmount
    # Calculates the total discounted amount including adjustments from previous lanes.
    #
    # @return [BigDecimal] the sum of the current amount and all previous lane discount amounts
    def discounted_amount
      amount + previous_lanes_discounts.sum(&:amount)
    end

    private

    # Returns discount objects added by promotion in lanes that come before the current lane.
    #
    # This method retrieves all discounts that were applied by promotion lanes with a priority
    # lower than the current lane, effectively getting discounts from earlier processing stages.
    #
    # @return [Array<Spree::Adjustment,SolidusPromotions::ShippingRateDiscount>] Discounts from previous lanes
    # @see #discounts_by_lanes
    # @see PromotionLane.previous_lanes
    def previous_lanes_discounts
      discounts_by_lanes(PromotionLane.previous_lanes)
    end
  end
end
