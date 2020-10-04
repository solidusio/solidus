# frozen_string_literal: true

module Spree
  class Variant < Spree::Base
    # Instances of this class represent the set of circumstances that influence how expensive a
    # variant is. For this particular pricing options class, country_iso and currency influence
    # the price of a variant.
    #
    # Pricing options can be instantiated from a line item or from the view context:
    # @see Spree::LineItem#pricing_options
    # @see Spree::Core::ControllerHelpers::Pricing#current_pricing_options
    #
    class PricingOptions
      # When editing variants in the admin, this is the standard price the admin interacts with:
      # The price in the admin's globally configured currency, for the admin's globally configured
      # country. These options get merged with any options the user provides when instantiating
      # new pricing options.
      # @see Spree::Config.default_pricing_options
      # @see #initialize
      # @return [Hash] The attributes that admin prices usually have
      #
      def self.default_price_attributes
        {
          currency: Spree::Config.currency,
          country_iso: Spree::Config.admin_vat_country_iso
        }
      end

      # This creates the correct pricing options for a line item, taking into account
      # its currency and tax address country, if available.
      # @see Spree::LineItem#set_pricing_attributes
      # @see Spree::LineItem#pricing_options
      # @return [Spree::Variant::PricingOptions] pricing options for pricing a line item
      #
      def self.from_line_item(line_item)
        tax_address = line_item.order.try!(:tax_address)
        new(
          currency: line_item.currency || Spree::Config.currency,
          country_iso: tax_address && tax_address.country.try!(:iso)
        )
      end

      # This creates the correct pricing options for a price, so that we can easily find other prices
      # with the same pricing-relevant attributes and mark them as non-default.
      # @see Spree::Price#set_default_price
      # @return [Spree::Variant::PricingOptions] pricing options for pricing a line item
      #
      def self.from_price(price)
        new(currency: price.currency, country_iso: price.country_iso)
      end

      # This creates the correct pricing options for a price, so the store owners can easily customize how to
      # find the pricing based on the view context, having available current_store, current_spree_user, request.host_name, etc.
      # @return [Spree::Variant::PricingOptions] pricing options for pricing a line item
      def self.from_context(context)
        new(
          currency: context.current_store.try!(:default_currency).presence || Spree::Config[:currency],
          country_iso: context.current_store.try!(:cart_tax_country_iso).presence
        )
      end

      # @return [Hash] The hash of exact desired attributes
      attr_reader :desired_attributes

      def initialize(desired_attributes = {})
        @desired_attributes = self.class.default_price_attributes.merge(desired_attributes)
      end

      # A slightly modified version of the `desired_attributes` Hash. Instead of
      # having "nil" or an actual country ISO code under the `:country_iso` key,
      # this creates an array under the country_iso key that includes both the actual
      # country iso we want and nil as a shorthand for the fallback price.
      # This is useful so that we can determine the availability of variants by price:
      # @see Spree::Variant.with_prices
      # @see Spree::Core::Search::Base#retrieve_products
      # @return [Hash] arguments to be passed into ActiveRecord.where()
      #
      def search_arguments
        search_arguments = desired_attributes
        search_arguments[:country_iso] = [desired_attributes[:country_iso], nil].flatten.uniq
        search_arguments
      end

      # Shorthand for accessing the currency part of the desired attributes
      # @return [String,nil] three-digit currency code or nil
      #
      def currency
        desired_attributes[:currency]
      end

      # Shorthand for accessing the country part of the desired attributes
      # @return [String,nil] two-digit country code or nil
      #
      def country_iso
        desired_attributes[:country_iso]
      end

      # Since the current pricing options determine the price to be shown to users,
      # product pages have to be cached and their caches invalidated using the data
      # from this object. This method makes it easy to use with Rails `cache` helper.
      # @return [String] cache key to be used in views
      #
      def cache_key
        desired_attributes.values.select(&:present?).map(&:to_s).join("/")
      end
    end
  end
end
