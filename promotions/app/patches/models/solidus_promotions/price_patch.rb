# frozen_string_literal: true

module SolidusPromotions
  module PricePatch
    def self.prepended(base)
      base.money_methods :discounted_amount
    end

    def discounts
      @discounts ||= []
    end

    attr_writer :discounts

    private

    # Returns discounts from specified promotion lanes.
    #
    # @param lanes [Array] An array of lanes to filter discounts by.
    # @return [Array<SolidusPromotions::ShippingRateDiscount] An array of discounts from the
    #   specified lans that are not marked for destruction.
    def discounts_by_lanes(lanes)
      discounts.select do |discount|
        discount.source.promotion.lane.in?(lanes)
      end
    end

    Spree::Price.prepend SolidusPromotions::DiscountedAmount
    Spree::Price.prepend self
  end
end
