# frozen_string_literal: true

module SolidusPromotions
  module ShippingRateDecorator
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

    Spree::ShippingRate.prepend SolidusPromotions::DiscountableAmount
    Spree::ShippingRate.prepend self
  end
end
