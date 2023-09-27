# frozen_string_literal: true

require_dependency "spree/calculator"

module SolidusFriendlyPromotions
  module Calculators
    class FlatRate < Spree::Calculator
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
