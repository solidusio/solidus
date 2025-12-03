# frozen_string_literal: true

module SolidusPromotions
  module DiscountedAmount
    class NotCalculatingPromotions < StandardError
      DEFAULT_MESSAGE = <<~MSG
        You're trying to call `#current_lane_discounts` without a current lane being set on `SolidusPromotions::PromotionLane.
        In order to set a current lane, wrap your call into a `PromotionLane.set` block:
        ```
        SolidusPromotions::PromotionLane.set(current_lane: "default") do
          # YOUR CODE HERE
        end
        ```
      MSG

      def initialize
        super(DEFAULT_MESSAGE)
      end
    end

    # Calculates the total discounted amount including adjustments from previous lanes.
    #
    # @return [BigDecimal] the sum of the current amount and all previous lane discount amounts
    def discounted_amount
      amount + previous_lanes_discounts.sum(&:amount)
    end

    # Returns discount objects from the current promotion lane.
    #
    # @return [Array<Spree::Adjustment,SolidusPromotions::ShippingRateDiscount>] Discounts from the current lane
    # @raise [NotCalculatingPromotions] if no promotion lane is currently being calculated
    def current_lane_discounts
      raise NotCalculatingPromotions unless PromotionLane.current_lane

      discounts_by_lanes([PromotionLane.current_lane])
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
