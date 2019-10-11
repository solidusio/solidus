# frozen_string_literal: true

module Solidus
  module Tax
    # Add tax adjustments to all line items and shipments in an order
    class OrderAdjuster
      attr_reader :order

      # @param [Solidus::Order] order to be adjusted
      def initialize(order)
        @order = order
      end

      # Creates tax adjustments for all taxable items (shipments and line items)
      # in the given order.
      def adjust!
        taxes = Solidus::Config.tax_calculator_class.new(order).calculate
        Solidus::OrderTaxation.new(order).apply(taxes)
      end
    end
  end
end
