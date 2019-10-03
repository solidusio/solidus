# frozen_string_literal: true

module Solidus
  module Stock
    class InventoryUnitBuilder
      def initialize(order)
        @order = order
      end

      def units
        @order.line_items.flat_map do |line_item|
          Array.new(line_item.quantity) do
            Solidus::InventoryUnit.new(
              pending: true,
              variant: line_item.variant,
              line_item: line_item
            )
          end
        end
      end
    end
  end
end
