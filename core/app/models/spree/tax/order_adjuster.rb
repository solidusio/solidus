module Spree
  module Tax
    # Add tax adjustments to all line items and shipments in an order
    class OrderAdjuster
      attr_reader :order

      include TaxHelpers

      # @param [Spree::Order] order to be adjusted
      def initialize(order)
        @order = order
      end

      # Creates tax adjustments for all taxable items (shipments and line items)
      # in the given order.
      def adjust!
        (order.line_items + order.shipments).each do |item|
          ItemAdjuster.new(item, order_wide_options).adjust!
        end
      end

      private

      def order_wide_options
        {
          rates_for_order: rates_for_order(order),
          rates_for_default_zone: rates_for_default_zone
        }
      end
    end
  end
end
