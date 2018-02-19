# frozen_string_literal: true

module Spree
  module Tax
    # Add tax adjustments to all line items and shipments in an order
    class OrderAdjuster
      attr_reader :order

      # @param [Spree::Order] order to be adjusted
      def initialize(order)
        @order = order
      end

      # Creates tax adjustments for all taxable items (shipments and line items)
      # in the given order.
      def adjust!
        taxes = Spree::Config.tax_calculator_class.new(order).calculate
        Spree::OrderTaxation.new(order).apply(taxes)
      end
    end
  end
end
