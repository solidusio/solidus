# @api private
# @note This is a helper class for Tax::OrderAdjuster.  It is marked as api
#   private because taxes should always be calculated on the entire order, so
#   external code should call Tax::OrderAdjuster instead of Tax::ItemAdjuster.
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
        @rates_for_order = options[:rates_for_order]
        @rates_for_default_zone = options[:rates_for_default_zone]
      end

      # Deletes all existing tax adjustments and creates new adjustments for all
      # (geographically and category-wise) applicable tax rates.
      def adjust!
        item.adjustments.destroy(item.adjustments.select(&:tax?))

        rates_for_item(item).each { |rate| rate.adjust(nil, item) }
      end
    end
  end
end
