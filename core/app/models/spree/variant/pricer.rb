module Spree
  class Variant
    # This class is responsible for assigning a price to a variant.
    # A variant can have multiple or even dynamic prices. The `price_for`
    # method determines which price applies under the given circumstances.
    #
    class Pricer
      # The pricing options represent "given circumstances" for a price: The currency
      # we need and the country that the price applies to.
      # Every pricer is designed to work with a particular set of pricing options
      # embodied in it's pricing options class.
      #
      def self.pricing_options_class
        Spree::Variant::PricingOptions
      end

      attr_reader :variant

      def initialize(variant)
        @variant = variant
      end

      # The variant's price, given a set of pricing options
      # @param [Spree::Variant::PricingOptions] price_options Pricing Options to abide by
      # @return [Spree::Money, nil] The most specific price for this set of pricing options.
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
