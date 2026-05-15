# frozen_string_literal: true

require_dependency "spree/calculator"

module Spree
  class Calculator::FlatRate < Calculator
    preference :amount, :decimal, default: 0
    preference :currency, :string, default: -> { Spree::Config[:currency] }

    def compute(object = nil)
      if object && preferred_currency.casecmp(object.currency).zero?
        BigDecimal(preferred_amount.to_s)
      else
        BigDecimal("0")
      end
    end
  end
end
