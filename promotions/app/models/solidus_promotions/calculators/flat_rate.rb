# frozen_string_literal: true

require_dependency "spree/calculator"

module SolidusPromotions
  module Calculators
    class FlatRate < Spree::Calculator
      include PromotionCalculator

      preference :amount, :decimal, default: 0
      preference :currency, :string, default: -> { Spree::Config[:currency] }

      def compute(object = nil)
        currency = object.order.currency
        if object && preferred_currency.casecmp(currency).zero?
          preferred_amount
        else
          0
        end
      end
    end
  end
end
