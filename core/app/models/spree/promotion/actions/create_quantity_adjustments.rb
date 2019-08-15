# frozen_string_literal: true

module Spree
  class Promotion < Spree::Base
    module Actions
      class CreateQuantityAdjustments < CreateItemAdjustments
        preference :group_size, :integer, default: 1

        has_many :line_item_actions, foreign_key: :action_id, dependent: :destroy
        has_many :line_items, through: :line_item_actions

        ##
        # Computes the amount for the adjustment based on the line item and any
        # other applicable items in the order. The rules for this specific
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
          adjustment_amount = calculator.compute(PartialLineItem.new(line_item))
          if !adjustment_amount.is_a?(BigDecimal)
            Spree::Deprecation.warn "#{calculator.class.name}#compute returned #{adjustment_amount.inspect}, it should return a BigDecimal"
          end
          adjustment_amount ||= BigDecimal(0)
          adjustment_amount = adjustment_amount.abs

          order = line_item.order
          line_items = actionable_line_items(order)

          actioned_line_items = order.line_item_adjustments.reload.
            select { |adjustment| adjustment.source == self && adjustment.amount < 0 }.
            map(&:adjustable)
          other_line_items = actioned_line_items - [line_item]

          applicable_quantity = total_applicable_quantity(line_items)
          used_quantity = total_used_quantity(other_line_items)
          usable_quantity = [
            applicable_quantity - used_quantity,
            line_item.quantity
          ].min

          persist_quantity(usable_quantity, line_item)

          amount = adjustment_amount * usable_quantity
          [line_item.amount, amount].min * -1
        end

        private

        def actionable_line_items(order)
          order.line_items.select do |item|
            promotion.line_item_actionable? order, item
          end
        end

        def total_applicable_quantity(line_items)
          total_quantity = line_items.sum(&:quantity)
          extra_quantity = total_quantity % preferred_group_size

          total_quantity - extra_quantity
        end

        def total_used_quantity(line_items)
          line_item_actions.where(
            line_item_id: line_items.map(&:id)
          ).sum(:quantity)
        end

        def persist_quantity(quantity, line_item)
          line_item_action = line_item_actions.where(
            line_item_id: line_item.id
          ).first_or_initialize
          line_item_action.quantity = quantity
          line_item_action.save!
        end

        ##
        # Used specifically for PercentOnLineItem calculator. That calculator uses
        # `line_item.amount`, however we might not necessarily want to discount the
        # entire amount. This class allows us to determine the discount per
        # quantity and then calculate the adjustment amount the way we normally do
        # for flat rate adjustments.
        class PartialLineItem
          def initialize(line_item)
            @line_item = line_item
          end

          def amount
            @line_item.price
          end

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
end
