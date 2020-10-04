# frozen_string_literal: true

module Spree
  module Stock
    class InventoryUnitBuilder
      def initialize(order)
        @order = order
      end

      def units
        @order.line_items.flat_map do |line_item|
          build_units(line_item, line_item.quantity)
        end
      end

      def missing_units_for_line_item(line_item)
        quantity = line_item.quantity - line_item.inventory_units.count
        build_units(line_item, quantity)
      end

      private

      def build_units(line_item, quantity)
        Array.new(quantity) do
          Spree::InventoryUnit.new(
            pending: true,
            variant: line_item.variant,
            line_item: line_item
          )
        end
      end
    end
  end
end
