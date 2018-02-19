# frozen_string_literal: true

require_dependency 'spree/calculator'
require_dependency 'spree/returns_calculator'

module Spree
  module Calculator::Returns
    class DefaultRefundAmount < ReturnsCalculator
      def compute(return_item)
        return 0.0.to_d if return_item.part_of_exchange?
        weighted_order_adjustment_amount(return_item.inventory_unit) + weighted_line_item_amount(return_item.inventory_unit)
      end

      private

      def weighted_order_adjustment_amount(inventory_unit)
        inventory_unit.order.adjustments.eligible.non_tax.sum(:amount) * percentage_of_order_total(inventory_unit)
      end

      def weighted_line_item_amount(inventory_unit)
        inventory_unit.line_item.total_before_tax / quantity_of_line_item(inventory_unit)
      end

      def percentage_of_order_total(inventory_unit)
        return 0.0 if inventory_unit.order.item_total_before_tax.zero?
        weighted_line_item_amount(inventory_unit) / inventory_unit.order.item_total_before_tax
      end

      def quantity_of_line_item(inventory_unit)
        BigDecimal(inventory_unit.line_item.quantity)
      end
    end
  end
end
