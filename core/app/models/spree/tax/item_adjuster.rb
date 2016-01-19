module Spree
  module Tax
    class ItemAdjuster
      attr_reader :item, :order

      def initialize(item, options = {})
        @item = item
        @order = @item.order
        # set the instance variable so `TaxRate.match` is only called when necessary
        @rates_for_order_zone = options[:rates_for_order_zone]
      end

      def adjust!
        return unless order_tax_zone
        # Using .destroy_all to make sure callbacks fire
        item.adjustments.tax.destroy_all

        TaxRate.store_pre_tax_amount(item, rates_for_item)

        rates_for_item.map { |rate| rate.adjust(order_tax_zone, item) }
      end

      private

      def rates_for_item
        @rates_for_item ||= rates_for_order_zone.select { |rate| rate.tax_category == item.tax_category }
      end

      def rates_for_order_zone
        @rates_for_order_zone ||= Spree::TaxRate.match(order_tax_zone)
      end

      def order_tax_zone
        @order_tax_zone ||= order.tax_zone
      end
    end
  end
end
