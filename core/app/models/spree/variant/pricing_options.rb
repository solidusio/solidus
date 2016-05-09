module Spree
  class Variant
    class PricingOptions
      def self.default_price_attributes
        {
          currency: Spree::Config.currency,
          country_iso: Spree::Config.admin_vat_country_iso
        }
      end

      def self.from_line_item(line_item)
        tax_address = line_item.order.try!(:tax_address)
        new(
          currency: line_item.order.try(:currency) || line_item.currency || Spree::Config.currency,
          country_iso: tax_address && tax_address.country.try!(:iso)
        )
      end

      def self.from_price(price)
        new(currency: price.currency, country_iso: price.country_iso)
      end

      attr_reader :desired_attributes

      def initialize(desired_attributes = {})
        @desired_attributes = self.class.default_price_attributes.merge(desired_attributes)
      end

      def search_arguments
        search_arguments = desired_attributes
        search_arguments[:country_iso] = [desired_attributes[:country_iso], nil].flatten.uniq
        search_arguments
      end

      def currency
        desired_attributes[:currency]
      end

      def country_iso
        desired_attributes[:country_iso]
      end

      def cache_key
        desired_attributes.values.select(&:present?).map(&:to_s).join("/")
      end
    end
  end
end
