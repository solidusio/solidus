module Spree
  module Tax
    # Adjust a single taxable item (line item or shipment)
    class ItemAdjuster
      attr_reader :item, :order

      include TaxHelpers

      # @param [Spree::LineItem,Spree::Shipment] item to adjust
      # @param [Hash] options like already known tax rates for the order's zone
      def initialize(item, options = {})
        @item = item
        @order = @item.order
        # set instance variable so `TaxRate.match` is only called when necessary
        @applicable_rates = options[:applicable_rates]
        @order_tax_zone = options[:order_tax_zone]
      end

      # Deletes all existing tax adjustments and creates new adjustments for all
      # (geographically and category-wise) applicable tax rates.
      #
      # Creating the adjustments will also run the ItemAdjustments class and
      # persist all taxation and promotion totals on the item.
      #
      # @return [Array<Spree::Adjustment>] newly created adjustments
      def adjust!
        return unless order_tax_zone(order)
        # Using .destroy_all to make sure callbacks fire
        item.adjustments.tax.destroy_all

        TaxRate.store_pre_tax_amount(item, rates_for_item)

        rates_for_item.map { |rate| rate.adjust(order_tax_zone(order), item) }
      end

      private

      def rates_for_item
        @rates_for_item ||= applicable_rates(order).select { |rate| rate.tax_category == item.tax_category }
      end
    end
  end
end
