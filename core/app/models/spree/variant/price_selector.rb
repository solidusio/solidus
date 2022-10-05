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
        Spree::Deprecation.warn(
          "price_for is deprecated and will be removed. The price_for method
          should return a Spree::Price as described. Please use
          #price_for_options and adjust your frontend code to explicitly call
          &.money where required"
        )
        price_for_options(price_options)&.money
      end

      # The variant's Spree::Price record, given a set of pricing options
      # @param [Spree::Variant::PricingOptions] price_options Pricing Options to abide by
      # @return [Spree::Price, nil] The most specific price for this set of pricing options.
      def price_for_options(price_options)
        sorted_prices_for(variant).detect do |price|
          (price.country_iso == price_options.desired_attributes[:country_iso] ||
           price.country_iso.nil?
          ) && price.currency == price_options.desired_attributes[:currency]
        end
      end

      private

      # Returns `#prices` prioritized for being considered as default price
      #
      # @return [Array<Spree::Price>]
      def sorted_prices_for(variant)
        variant.prices.sort_by do |price|
          [
            price.country_iso.nil? ? 0 : 1,
            price.updated_at || Time.zone.now,
            price.id || Float::INFINITY,
          ]
        end.reverse
      end
    end
  end
end
