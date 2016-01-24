module Spree
  module Tax
    class OrderAdjuster
      attr_reader :order

      include TaxHelpers

      def initialize(order)
        @order = order
      end

      def adjust!
        return unless order_tax_zone

        (order.line_items + order.shipments).each do |item|
          ItemAdjuster.new(item, rates_for_order_zone: rates_for_order_zone).adjust!
        end
      end
    end
  end
end
