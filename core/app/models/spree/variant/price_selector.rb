# frozen_string_literal: true

module Spree
  class Variant < Spree::Base
    # This class is responsible for selecting a price for a variant given certain pricing options.
    # A variant can have multiple or even dynamic prices. The `price_for`
    # method determines which price applies under the given circumstances.
    #
    class PriceSelector
      # The pricing options represent "given circumstances" for a price: The currency
      # we need and the country that the price applies to.
      # Every price selector is designed to work with a particular set of pricing options
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
        variant.currently_valid_prices.detect do |price|
          ( price.country_iso == price_options.desired_attributes[:country_iso] ||
            price.country_iso.nil?
          ) && price.currency == price_options.desired_attributes[:currency]
        end.try!(:money)
      end
    end
  end
end
