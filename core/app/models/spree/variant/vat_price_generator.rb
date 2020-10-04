# frozen_string_literal: true

module Spree
  class Variant < Spree::Base
    # This class generates gross prices for all countries that have VAT configured.
    # The prices will include their respective VAT rates. It will also generate an
    # export (net) price for any country that doesn't have VAT.
    # @example
    #   The admin is configured to show German gross prices
    #   (Spree::Config.admin_vat_country_iso == "DE")
    #
    #   There is VATs configured for Germany (19%) and Finland (24%).
    #   The VAT price generator is run on a variant with a base (German) price of 10.00.
    #   The Price Generator will generate:
    #     - A price for Finland (country_id == "FI"): 10.42
    #     - A price for any other country (country_id == nil): 8.40
    #
    class VatPriceGenerator
      attr_reader :variant

      def initialize(variant)
        @variant = variant
      end

      def run
        # Early return if there is no VAT rates in the current store.
        return if !variant.tax_category || variant_vat_rates.empty?

        country_isos_requiring_price.each do |country_iso|
          # Don't re-create the default price
          next if variant.default_price && variant.default_price.country_iso == country_iso

          foreign_price = find_or_initialize_price_by(country_iso, variant.default_price.currency)

          foreign_price.amount = variant.default_price.net_amount * (1 + vat_for_country_iso(country_iso))
        end
      end

      private

      def find_or_initialize_price_by(country_iso, currency)
        variant.prices.detect do |price|
          price.country_iso == country_iso && price.currency == currency
        end || variant.prices.build(country_iso: country_iso, currency: currency)
      end

      # nil is added to the array so we always have an export price.
      def country_isos_requiring_price
        return [nil] unless variant.tax_category
        [nil] + variant_vat_rates.map(&:zone).flat_map(&:countries).flat_map(&:iso)
      end

      def vat_for_country_iso(country_iso)
        return 0 unless variant.tax_category
        variant_vat_rates.for_country(Spree::Country.find_by(iso: country_iso)).sum(:amount)
      end

      def variant_vat_rates
        @variant_vat_rates ||= variant.tax_category.tax_rates.included_in_price
      end
    end
  end
end
