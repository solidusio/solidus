# frozen_string_literal: true

module SolidusPromotions
  module PricePatch
    def self.prepended(base)
      base.alias_method :discounted_amount, :discountable_amount
      base.alias_method :discounts, :current_discounts
      base.money_methods :discounted_amount
    end

    Spree::Price.prepend SolidusPromotions::DiscountableAmount
    Spree::Price.prepend self
  end
end
