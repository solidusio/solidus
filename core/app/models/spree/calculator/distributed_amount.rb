# frozen_string_literal: true

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
      return 0 unless line_item
      return 0 unless preferred_currency.casecmp(line_item.currency).zero?
      return 0 unless calculable.promotion.line_item_actionable?(line_item.order, line_item)
      Spree::DistributedAmountsHandler.new(
        actionable_line_items(line_item.order),
        preferred_amount
      ).amount(line_item)
    end

    private

    def actionable_line_items(order)
      order.line_items.select do |line_item|
        calculable.promotion.line_item_actionable?(order, line_item)
      end
    end
  end
end
