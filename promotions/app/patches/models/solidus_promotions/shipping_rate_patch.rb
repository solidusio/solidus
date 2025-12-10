# frozen_string_literal: true

module SolidusPromotions
  module ShippingRatePatch
    def self.prepended(base)
      base.class_eval do
        has_many :discounts,
          class_name: "SolidusPromotions::ShippingRateDiscount",
          foreign_key: :shipping_rate_id,
          dependent: :destroy,
          inverse_of: :shipping_rate,
          autosave: true

        money_methods :total_before_tax, :promo_total
      end
    end

    def total_before_tax
      amount + promo_total
    end

    def promo_total
      discounts.sum(&:amount)
    end

    private

    # Returns discounts from specified promotion lanes.
    #
    # @param lanes [Array] An array of lanes to filter discounts by.
    # @return [Array<SolidusPromotions::ShippingRateDiscount] An array of discounts from the
    #   specified lans that are not marked for destruction.
    def discounts_by_lanes(lanes)
      discounts.select do |discount|
        !discount.marked_for_destruction? &&
          discount.benefit.promotion.lane.in?(lanes)
      end
    end

    Spree::ShippingRate.prepend SolidusPromotions::DiscountableAmount
    Spree::ShippingRate.prepend SolidusPromotions::DiscountedAmount
    Spree::ShippingRate.prepend self
  end
end
