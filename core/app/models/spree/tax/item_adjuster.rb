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

        TaxRate.store_pre_tax_amount(item, rates_for_item)

        if outside_default_vat_zone?
          handle_deductable_default_vats
        end

        rates_for_item.map { |rate| rate.adjust(order_tax_zone, item) }
      end

      private

      def handle_deductable_default_vats
        # Imagine with me this scenario:
        # You are living in Spain and you have a store which ships to France.
        # Spain is therefore your default tax rate.
        # When you ship to Spain, you want the Spanish rate to apply.
        # When you ship to France, you want the French rate to apply.
        #
        # Normally, Spree would notice that you have two potentially applicable
        # tax rates for one particular item.
        # When you ship to Spain, only the Spanish one will apply.
        # When you ship to France, you'll see a Spanish refund AND a French tax.
        # This little bit of code at the end stops the Spanish refund from appearing.
        #
        # For further discussion, see https://github.com/spree/spree/issues/4397 and https://github.com/spree/spree/issues/4327.
        return if rates_for_item.any? { |rate| rate.included_in_price }

        default_rates_for_item.each do |default_rate|
          default_rate.adjust(order_tax_zone, item)
        end
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
