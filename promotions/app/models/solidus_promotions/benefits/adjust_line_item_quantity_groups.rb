# frozen_string_literal: true

module SolidusPromotions
  module Benefits
    class AdjustLineItemQuantityGroups < AdjustLineItem
      preference :group_size, :integer, default: 1

      ##
      # Computes the amount for the adjustment based on the line item and any
      # other applicable items in the order. The conditions for this specific
      # adjustment are as follows:
      #
      # = Setup
      #
      # We have a quantity group promotion on t-shirts. If a user orders 3
      # t-shirts, they get $5 off of each. The shirts come in one size and three
      # colours: red, blue, and white.
      #
      # == Scenario 1
      #
      # User has 2 red shirts, 1 white shirt, and 1 blue shirt in their
      # order. We want to compute the adjustment amount for the white shirt.
      #
      # *Result:* -$5
      #
      # *Reasoning:* There are a total of 4 items that are eligible for the
      # promotion. Since that is greater than 3, we can discount the items. The
      # white shirt has a quantity of 1, therefore it will get discounted by
      # +adjustment_amount * 1+ or $5.
      #
      # === Scenario 1-1
      #
      # What about the blue shirt? How much does it get discounted?
      #
      # *Result:* $0
      #
      # *Reasoning:* We have a total quantity of 4. However, we only apply the
      # adjustment to groups of 3. Assuming the white and red shirts have already
      # had their adjustment calculated, that means 3 units have been discounted.
      # Leaving us with a lonely blue shirt that isn't part of a group of 3.
      # Therefore, it does not receive the discount.
      #
      # == Scenario 2
      #
      # User has 4 red shirts in their order. What is the amount?
      #
      # *Result:* -$15
      #
      # *Reasoning:* The total quantity of eligible items is 4, so we the
      # adjustment will be non-zero. However, we only apply it to groups of 3,
      # therefore there is one extra item that is not eligible for the
      # adjustment. +adjustment_amount * 3+ or $15.
      #
      def compute_amount(line_item)
        adjustment_amount = calculator.compute(Item.new(line_item))
        return BigDecimal(0) if adjustment_amount.nil? || adjustment_amount.zero?

        adjustment_amount = adjustment_amount.abs

        order = line_item.order
        line_items = applicable_line_items(order)

        item_units = line_items.sort_by do |applicable_line_item|
          [-applicable_line_item.quantity, applicable_line_item.id]
        end.flat_map do |applicable_line_item|
          Array.new(applicable_line_item.quantity) do
            Item.new(applicable_line_item)
          end
        end

        item_units_in_groups = item_units.in_groups_of(preferred_group_size, false)
        item_units_in_groups.select! { |group| group.length == preferred_group_size }
        usable_quantity = item_units_in_groups.flatten.count { |item_unit| item_unit.line_item == line_item }

        amount = adjustment_amount * usable_quantity
        [line_item.discountable_amount, amount].min * -1
      end

      ##
      # Used specifically for PercentOnLineItem calculator. That calculator uses
      # `line_item.amount`, however we might not necessarily want to discount the
      # entire amount. This class allows us to determine the discount per
      # quantity and then calculate the adjustment amount the way we normally do
      # for flat rate adjustments.
      class Item
        attr_reader :line_item

        def initialize(line_item)
          @line_item = line_item
        end

        def discountable_amount
          @line_item.discountable_amount / @line_item.quantity.to_d
        end
        alias_method :amount, :discountable_amount

        def order
          @line_item.order
        end

        def currency
          @line_item.currency
        end
      end
    end
  end
end
