# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    # Promotion condition for ensuring an order contains a minimum quantity of
    # applicable items.
    #
    # This promotion condition is only compatible with the "all" match policy. It
    # doesn't make a lot of sense to use it without that policy as it reduces
    # it to a simple quantity check across the entire order which would be
    # better served by an item total condition.
    class MinimumQuantity < Condition
      include OrderLevelCondition

      validates :preferred_minimum_quantity, numericality: {only_integer: true, greater_than: 0}

      preference :minimum_quantity, :integer, default: 1

      # Will look at all of the "applicable" line items in the order and
      # determine if the sum of their quantity is greater than the minimum.
      #
      # "Applicable" items are ones that pass all eligibility checks of applicable conditions.
      #
      # When false is returned, the reason will be included in the
      # `eligibility_errors` object.
      #
      # @param order [Spree::Order] the order we want to check eligibility on
      # @return [Boolean] true if promotion is eligible, false otherwise
      def eligible?(order)
        if benefit.applicable_line_items(order).sum(&:quantity) < preferred_minimum_quantity
          eligibility_errors.add(
            :base,
            eligibility_error_message(:quantity_less_than_minimum, count: preferred_minimum_quantity),
            error_code: :quantity_less_than_minimum
          )
        end

        eligibility_errors.empty?
      end
    end
  end
end
