# frozen_string_literal: true

require_dependency 'spree/calculator'

module Spree
  class Calculator::FlatPercentItemTotal < Calculator
    preference :flat_percent, :decimal, default: 0
    attr_reader :object

    def compute(object)
      @object = object
      preferred_currency = order.currency
      currency_exponent = ::Money::Currency.find(preferred_currency).exponent
      computed_amount = (calculable_amount * preferred_flat_percent / 100).round(currency_exponent)

      # We don't want to cause the promotion adjustments to push the order into a negative total.
      if computed_amount > object.amount
        object.amount
      else
        computed_amount
      end
    end

    private

    def order
      object.is_a?(Order) ? object : object.order
    end

    def calculable_amount
      if object.is_a?(Order)
        object.promotable_item_total
      else
        object.amount
      end
    end
  end
end
