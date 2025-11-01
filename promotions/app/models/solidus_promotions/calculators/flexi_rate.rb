# frozen_string_literal: true

require_dependency "spree/calculator"

module SolidusPromotions
  module Calculators
    # A calculator that applies different discount amounts for the first item and additional items.
    #
    # This calculator allows setting a discount for the first item in a line item and a
    # different discount for each additional item. Optionally, a maximum number of items
    # can be specified to limit the discount calculation.
    #
    # @example
    #   # $5 off first item, $2 off each additional item, max 5 items
    #   calculator = FlexiRate.new(
    #     preferred_first_item: 5,
    #     preferred_additional_item: 2,
    #     preferred_max_items: 5
    #   )
    #   # Line item with quantity 3: $5 + ($2 × 2) = $9 discount
    #   # Line item with quantity 10: $5 + ($2 × 4) = $13 discount (limited to 5 items)
    class FlexiRate < Spree::Calculator
      include PromotionCalculator

      preference :first_item, :decimal, default: Spree::ZERO
      preference :additional_item, :decimal, default: Spree::ZERO
      preference :max_items, :integer, default: 0
      preference :currency, :string, default: -> { Spree::Config[:currency] }

      # Computes the discount amount for a line item based on its quantity.
      #
      # Calculates the total discount by applying the first_item rate to the first unit
      # and the additional_item rate to remaining units. If max_items is set (non-zero),
      # the calculation is limited to that number of items.
      #
      # @param line_item [Spree::LineItem] The line item to calculate the discount for
      #
      # @return [BigDecimal] The total discount amount based on quantity and preferences
      #
      # @example Computing discount for a line item with 3 items
      #   calculator = FlexiRate.new(preferred_first_item: 10, preferred_additional_item: 5)
      #   line_item.quantity # => 3
      #   calculator.compute_line_item(line_item) # => 20.0 (10 + 5 + 5)
      #
      # @example Computing discount with max_items limit
      #   calculator = FlexiRate.new(
      #     preferred_first_item: 10,
      #     preferred_additional_item: 5,
      #     preferred_max_items: 2
      #   )
      #   line_item.quantity # => 5
      #   calculator.compute_line_item(line_item) # => 15.0 (10 + 5, limited to 2 items)
      def compute_line_item(line_item)
        items_count = line_item.quantity
        items_count = [items_count, preferred_max_items].min unless preferred_max_items.zero?

        return Spree::ZERO if items_count.zero?

        additional_items_count = items_count - 1
        preferred_first_item + preferred_additional_item * additional_items_count
      end
    end
  end
end
