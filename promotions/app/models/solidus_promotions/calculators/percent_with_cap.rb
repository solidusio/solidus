# frozen_string_literal: true

module SolidusPromotions
  module Calculators
    # A calculator that applies a percentage-based discount with a maximum cap.
    #
    # This calculator computes a discount as a percentage of the line item's discountable amount,
    # but limits the total discount to a maximum amount distributed across all applicable line items.
    # The actual discount applied is the lesser of the percentage discount and the proportional
    # share of the maximum cap.
    #
    # @example
    #   calculator = PercentWithCap.new(preferred_percent: 20, preferred_max_amount: 50)
    #   # Line item with $100 discountable amount
    #   # Percentage would be $20 (20% of $100)
    #   # But if the max cap distributes only $15 to this item, it gets $15
    class PercentWithCap < Spree::Calculator
      include PromotionCalculator

      preference :percent, :decimal, default: 0
      preference :max_amount, :integer, default: 100

      # Computes the discount for a line item, capped at a maximum amount.
      #
      # Calculates both a percentage-based discount and a distributed maximum discount,
      # then returns whichever is smaller. This ensures the discount never exceeds
      # the line item's proportional share of the maximum cap, even if the percentage
      # would result in a larger discount.
      #
      # @param line_item [Spree::LineItem] The line item to calculate the discount for
      #
      # @return [BigDecimal] The discount amount, limited by both the percentage and the max cap
      #
      # @example Computing discount when percentage is lower than cap
      #   calculator = PercentWithCap.new(preferred_percent: 10, preferred_max_amount: 100)
      #   line_item.discountable_amount # => 50.00
      #   # Percent discount: $5 (10% of $50)
      #   # Max distributed: $25 (assuming equal distribution)
      #   calculator.compute_line_item(line_item) # => 5.00
      #
      # @example Computing discount when cap is lower than percentage
      #   calculator = PercentWithCap.new(preferred_percent: 50, preferred_max_amount: 10)
      #   line_item.discountable_amount # => 100.00
      #   # Percent discount: $50 (50% of $100)
      #   # Max distributed: $10 (assuming single line item)
      #   calculator.compute_line_item(line_item) # => 10.00
      #
      # @see DistributedAmount
      def compute_line_item(line_item)
        percent_discount = round_to_currency(line_item.discountable_amount * preferred_percent / 100, line_item.order.currency)
        max_discount = DistributedAmount.new(
          calculable:,
          preferred_amount: preferred_max_amount
        ).compute_line_item(line_item)

        [percent_discount, max_discount].min
      end
    end
  end
end
