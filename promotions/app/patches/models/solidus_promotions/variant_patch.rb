# frozen_string_literal: true

module SolidusPromotions
  module VariantPatch
    class VariantNotDiscounted < StandardError; end
    attr_accessor :discountable_price

    def self.prepended(base)
      base.extend Spree::DisplayMoney

      base.money_methods :discounted_price, :undiscounted_price
    end

    def undiscounted_price
      raise VariantNotDiscounted unless discountable_price
      discountable_price.amount
    end

    def discounted_price
      raise VariantNotDiscounted unless discountable_price
      discountable_price.discountable_amount
    end

    def price_discounts
      raise VariantNotDiscounted unless discountable_price
      discountable_price.current_discounts
    end

    Spree::Variant.prepend self
  end
end
