module Spree
  module Tax
    class ItemAdjuster
      attr_reader :item, :order

      include TaxHelpers

      def initialize(item, options = {})
        @item = item
        @order = @item.order
        # set caching instance variables so order-wide calculations are only done
        # once per order
        @rates_for_order_zone = options[:rates_for_order_zone]
        @rates_for_default_zone = options[:rates_for_default_zone]
        @order_tax_zone = options[:order_tax_zone]
        @default_tax_zone = options[:default_tax_zone]
        @outside_default_vat_zone = options[:outside_default_vat_zone]
      end

      def adjust!
        return unless order_tax_zone
        # Using .destroy_all to make sure callbacks fire
        item.adjustments.tax.destroy_all

        if outside_default_vat_zone?
          adjust_item_price
        end

        TaxRate.store_pre_tax_amount(@item, rates_for_item)

        rates_for_item.map { |rate| rate.adjust(order_tax_zone, item) }
      end

      private

      def adjust_item_price
        default_vat_amounts = default_rates_for_item.map(&:amount).sum
        included_item_rate_amounts = rates_for_item.select(&:included_in_price).map(&:amount).sum
        item.price = item.initial_price / (1 + default_vat_amounts) * (1 + included_item_rate_amounts)
      end

      def default_rates_for_item
        rates_for_default_zone.included_in_price.select { |rate| rate.tax_category == item.tax_category }
      end

      def rates_for_item
        @rates_for_item ||= rates_for_order_zone.select { |rate| rate.tax_category == item.tax_category }
      end
    end
  end
end
