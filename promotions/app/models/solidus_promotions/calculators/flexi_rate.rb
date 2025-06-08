# frozen_string_literal: true

require_dependency "spree/calculator"

module SolidusPromotions
  module Calculators
    class FlexiRate < Spree::Calculator
      include PromotionCalculator

      preference :first_item, :decimal, default: 0
      preference :additional_item, :decimal, default: 0
      preference :max_items, :integer, default: 0
      preference :currency, :string, default: -> { Spree::Config[:currency] }

      def compute_line_item(line_item)
        compute_for_quantity(line_item.quantity)
      end

      def compute_price(price, options = {})
        order = options[:order]
        desired_quantity = options[:quantity] || 0
        return Spree::ZERO if desired_quantity.zero?

        already_ordered_quantity = if order
          order.line_items.detect do |line_item|
            line_item.variant == price.variant
          end&.quantity || 0
        else
          0
        end
        possible_discount = compute_for_quantity(already_ordered_quantity + desired_quantity)
        existing_discount = compute_for_quantity(already_ordered_quantity)
        round_to_currency(
          (possible_discount - existing_discount) / desired_quantity,
          price.currency
        )
      end

      private

      def compute_for_quantity(quantity)
        items_count = preferred_max_items.zero? ? quantity : [quantity, preferred_max_items].min

        return Spree::ZERO if items_count == 0

        additional_items_count = items_count - 1
        preferred_first_item + preferred_additional_item * additional_items_count
      end
    end
  end
end
