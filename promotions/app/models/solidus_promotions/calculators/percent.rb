# frozen_string_literal: true

require_dependency "spree/calculator"

module SolidusPromotions
  module Calculators
    class Percent < Spree::Calculator
      include PromotionCalculator

      preference :percent, :decimal, default: 0

      def compute(object)
        preferred_currency = object.order.currency
        currency_exponent = ::Money::Currency.find(preferred_currency).exponent
        (object.discountable_amount * preferred_percent / 100).round(currency_exponent)
      end
    end
  end
end
