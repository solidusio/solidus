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
          tax_category = rate.tax_categories.find { |tax_cat| tax_cat.id == tax_category_id }
          next unless tax_category && tax_applicable?(tax_category, item.order.tax_address)

          rate.active? && rate.tax_categories.map(&:id).include?(tax_category_id)
        end
      end

      # Determine if tax is applicable based on tax category and address
      #
      # @param [Spree::TaxCategory] tax_category
      #   the tax category to check tax_reverse_charge_mode
      # @param [Spree::Address] address
      #   the address to check reverse_charge_status
      # @return [Boolean] true if tax is applicable, false otherwise
      def tax_applicable?(tax_category, address)
        case tax_category.tax_reverse_charge_mode
          # Strict mode: Tax applies only if the address is NOT enabled (reverse charge)
        when 'strict'
          !address.reverse_charge_status_enabled?
          # Loose mode: Tax applies only if the address is explicitly disabled
        when 'loose'
          address.reverse_charge_status_disabled?
          # Tax always applies
        when 'disabled'
          true
        end
      end
    end
  end
end
