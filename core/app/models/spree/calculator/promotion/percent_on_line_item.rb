# frozen_string_literal: true

require_dependency 'spree/calculator'

module Spree
  # This calculator provides a percentage-based discount for each applicable
  # line item in an order.
  class Calculator::Promotion::PercentOnLineItem < Calculator
    preference :percent, :decimal, default: 0

    def compute(object)
      (object.amount * preferred_percent) / 100
    end
  end
end
