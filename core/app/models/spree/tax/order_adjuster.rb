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
          ItemAdjuster.new(item, order_wide_options).adjust!
        end
      end

      private

      def order_wide_options
        {
          rates_for_order_zone: rates_for_order_zone,
          rates_for_default_zone: rates_for_default_zone,
          order_tax_zone: order_tax_zone,
          default_tax_zone: default_tax_zone,
          outside_default_vat_zone: outside_default_vat_zone?
        }
      end
    end
  end
end
