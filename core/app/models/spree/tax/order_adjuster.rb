module Spree
  module Tax
    class OrderAdjuster
      attr_reader :order

      def initialize(order)
        @order = order
      end

      def adjust!
        Spree::TaxRate.adjust(order.tax_zone, order.line_items + order.shipments)
      end
    end
  end
end
