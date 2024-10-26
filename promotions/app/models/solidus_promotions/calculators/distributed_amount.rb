# frozen_string_literal: true

require_dependency "spree/calculator"

# This is a calculator for line item adjustment benefits. It accepts a line item
# and calculates its weighted adjustment amount based on the value of the
# preferred amount and the price of the other line items. More expensive line
# items will receive a greater share of the preferred amount.
module SolidusPromotions
  module Calculators
    class DistributedAmount < Spree::Calculator
      include PromotionCalculator

      preference :amount, :decimal, default: 0
      preference :currency, :string, default: -> { Spree::Config[:currency] }

      def compute_line_item(line_item)
        return 0 unless line_item
        return 0 unless preferred_currency.casecmp(line_item.currency).zero?

        distributable_line_items = calculable.applicable_line_items(line_item.order)
        return 0 unless line_item.in?(distributable_line_items)

        DistributedAmountsHandler.new(
          distributable_line_items,
          preferred_amount
        ).amount(line_item)
      end
    end
  end
end
