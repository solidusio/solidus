module Spree
  class Variant
    class PriceGenerator
      attr_reader :variant

      def initialize(variant)
        @variant = variant
      end

      def run
        country_isos_requiring_price.each do |country_iso|
          # No double prices
          next if variant.prices.map(&:country_iso).include?(country_iso)
          # Also don't re-create the default price
          next if variant.default_price && variant.default_price.country_iso == country_iso
          variant.prices.build(
            country_iso: country_iso,
            amount: variant.default_price.net_amount * (1 + vat_for_country_iso(country_iso)),
            currency: variant.default_price.currency,
            is_default: true
          )
        end
      end

      private

      def country_isos_requiring_price
        return [nil] unless variant.tax_category
        [nil] + variant_vat_rates.map(&:zone).flat_map(&:countries).flat_map(&:iso)
      end

      def vat_for_country_iso(country_iso)
        return 0 unless variant.tax_category
        variant_vat_rates.for_address(
          Spree::Tax::TaxLocation.new(country: Spree::Country.find_by(iso: country_iso))
        ).sum(:amount)
      end

      def variant_vat_rates
        variant.tax_category.tax_rates.where(included_in_price: true)
      end
    end
  end
end
