module Spree
  class Variant
    class Pricer
      def self.pricing_options_class
        Spree::Variant::PricingOptions
      end

      attr_reader :variant

      def initialize(variant)
        @variant = variant
      end

      def price_for(price_options)
        variant.prices
          .currently_valid
          .order("country_iso IS NULL") # Make sure the nils come last
          .find_by(
            price_options.search_arguments
          ).try!(:money)
      end
    end
  end
end
