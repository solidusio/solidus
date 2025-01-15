# frozen_string_literal: true

module Spree
  module Tax
    module TaxHelpers
      private

      # Select active rates matching tax category and address
      #
      # @private
      # @param [Spree::LineItem, Spree::Shipment, Spree::ShippingRate] item
      #   the line item, shipment, or shipping rate to select rates for
      # @return [Array<Spree::TaxRate>] the active Tax Rates that match both
      #   Tax Category and the item's order's tax address
      def rates_for_item(item)
        @rates_for_item ||= Spree::TaxRate.item_level.for_address(item.order.tax_address)
        # try is used here to ensure that a LineItem has rates selected for the
        # currently configured Tax Category. Shipments and ShippingRates do not
        # implement variant_tax_category_id, so try is necessary instead of .&
        tax_category_id = item.try(:variant_tax_category_id) || item.tax_category_id

        @rates_for_item.select do |rate|
          rate.active? && rate.tax_categories.map(&:id).include?(tax_category_id)
        end
      end
    end
  end
end
