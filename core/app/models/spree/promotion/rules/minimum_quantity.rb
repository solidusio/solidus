# frozen_string_literal: true

module Spree
  class Promotion
    module Rules
      # Promotion rule for ensuring an order contains a minimum quantity of
      # actionable items.
      #
      # This promotion rule is only compatible with the "all" match policy. It
      # doesn't make a lot of sense to use it without that policy as it reduces
      # it to a simple quantity check across the entire order which would be
      # better served by an item total rule.
      class MinimumQuantity < PromotionRule
        validates :preferred_minimum_quantity, numericality: { only_integer: true, greater_than: 0 }

        preference :minimum_quantity, :integer, default: 1

        # What type of objects we should run our eligiblity checks against. In
        # this case, our rule only applies to an entire order.
        #
        # @param promotable [Spree::Order,Spree::LineItem]
        # @return [Boolean] true if promotable is a Spree::Order, false
        #   otherwise
        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        # Will look at all of the "actionable" line items in the order and
        # determine if the sum of their quantity is greater than the minimum.
        #
        # "Actionable" items are ones where they pass the "actionable?" check of
        # all rules on the promotion. (e.g.: Match product/taxon when one of
        # those rules is present.)
        #
        # When false is returned, the reason will be included in the
        # `eligibility_errors` object.
        #
        # @param order [Spree::Order] the order we want to check eligibility on
        # @param _options [Hash] ignored
        # @return [Boolean] true if promotion is eligible, false otherwise
        def eligible?(order, _options = {})
          actionable_line_items = order.line_items.select do |line_item|
            promotion.rules.all? { _1.actionable?(line_item) }
          end

          if actionable_line_items.sum(&:quantity) < preferred_minimum_quantity
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
end
