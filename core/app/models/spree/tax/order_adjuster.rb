module Spree
  module Tax
    class OrderAdjuster
      attr_reader :order

      def initialize(order)
        @order = order
      end

      def adjust!
        return unless order_tax_zone

        (order.line_items + order.shipments).each do |item|
          ItemAdjuster.new(item, rates_for_order_zone: rates_for_order_zone).adjust!
        end
      end

      private

      # When adjusting multiple items, we don't want to
      # look up the zone rates for each individual item
      def rates_for_order_zone
        @rates_for_order_zone ||= Spree::TaxRate.match(order_tax_zone)
      end

      def order_tax_zone
        @order_tax_zone ||= order.tax_zone
      end
    end
  end
end
