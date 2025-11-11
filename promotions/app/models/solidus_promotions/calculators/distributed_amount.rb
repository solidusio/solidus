# frozen_string_literal: true

require_dependency "spree/calculator"

module SolidusPromotions
  module Calculators
    # A calculator that distributes a fixed discount amount across line items based on their value.
    #
    # This calculator takes a preferred total discount amount and distributes it proportionally
    # across applicable line items based on their prices. More expensive line items receive
    # a greater share of the discount.
    #
    # @example
    #   # Given a $30 discount and line items worth $100, $50, and $50:
    #   # - $100 line item receives $15 discount (50% of total value)
    #   # - $50 line item receives $7.50 discount (25% of total value)
    #   # - $50 line item receives $7.50 discount (25% of total value)
    class DistributedAmount < Spree::Calculator
      include PromotionCalculator

      preference :amount, :decimal, default: Spree::ZERO
      preference :currency, :string, default: -> { Spree::Config[:currency] }

      # Computes the weighted discount amount for a specific line item.
      #
      # The discount is calculated by distributing the preferred amount across all
      # applicable line items, weighted by their prices. Returns 0 if:
      # - The line item is nil
      # - The currency doesn't match the preferred currency
      # - The line item is not in the list of applicable line items
      #
      # @param line_item [Spree::LineItem] The line item to calculate the discount for
      #
      # @return [BigDecimal] The weighted discount amount for this line item
      #
      # @example Computing discount for a line item
      #   calculator = DistributedAmount.new(preferred_amount: 20, preferred_currency: 'USD')
      #   # Assuming there are 2 line items: one at $80, one at $20
      #   calculator.compute_line_item(expensive_line_item) # => 16.0 (80% of 20)
      #   calculator.compute_line_item(cheaper_line_item)   # => 4.0 (20% of 20)
      #
      # @see DistributedAmountsHandler
      def compute_line_item(line_item)
        return Spree::ZERO unless line_item
        return Spree::ZERO unless preferred_currency.casecmp(line_item.currency).zero?

        distributable_line_items = calculable.applicable_line_items(line_item.order)
        return Spree::ZERO unless line_item.in?(distributable_line_items)

        DistributedAmountsHandler.new(
          distributable_line_items,
          preferred_amount
        ).amount(line_item)
      end
    end
  end
end
