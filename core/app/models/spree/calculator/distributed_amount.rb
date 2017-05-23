require_dependency 'spree/calculator'

# This is a calculator for line item adjustment actions. It accepts a line item
# and calculates its weighted adjustment amount based on the value of the
# preferred amount and the price of the other line items. More expensive line
# items will receive a greater share of the preferred amount.

module Spree
  class Calculator::DistributedAmount < Calculator
    preference :amount, :decimal, default: 0
    preference :currency, :string, default: -> { Spree::Config[:currency] }

    def compute_line_item(line_item)
      if line_item && preferred_currency.casecmp(line_item.currency).zero?
        Spree::DistributedAmountsHandler.new(
          line_item,
          preferred_amount
        ).amount
      else
        0
      end
    end
  end
end
