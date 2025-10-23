# frozen_string_literal: true

require_dependency "spree/calculator"

module SolidusPromotions
  module Calculators
    class Percent < Spree::Calculator
      include PromotionCalculator

      preference :percent, :decimal, default: 0

      def compute(object)
        round_to_currency(object.discountable_amount * preferred_percent / 100, object.order.currency)
      end
    end
  end
end
