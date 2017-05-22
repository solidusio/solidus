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

      # This updates the amounts for adjustments which already exist and
      # creates and remove adjustments as needed to match the applicable
      # (geographically and category-wise) tax rates.
      def adjust!
        rates = rates_for_item(item)

        tax_adjustments = item.adjustments.select(&:tax?)
        active_adjustments = rates.map do |rate|
          # Find an existing adjustment from the same source.
          # All tax adjustments already have source_type == 'Spree::TaxRate' so
          # we need only check source_id.
          adjustment = tax_adjustments.detect { |a| a.source_id == rate.id }
          if adjustment
            adjustment.update!
            adjustment
          else
            # Create a new adjustment
            rate.adjust(nil, item)
          end
        end

        unmatched_adjustments = tax_adjustments - active_adjustments

        # Remove any tax adjustments tied to rates which no longer match
        item.adjustments.destroy(unmatched_adjustments)
      end
    end
  end
end
