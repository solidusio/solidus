# frozen_string_literal: true

module Spree
  module DefaultPrice
    extend ActiveSupport::Concern

    included do
      delegate :display_price, :display_amount, :price, to: :default_price, allow_nil: true
      delegate :price=, to: :default_price_or_build

      # @see Spree::Variant::PricingOptions.default_price_attributes
      def self.default_pricing
        Spree::Config.default_pricing_options.desired_attributes
      end
    end

    # Returns `#prices` prioritized for being considered as default price
    #
    # @return [Array<Spree::Price>]
    def currently_valid_prices
      prices.currently_valid
    end

    # Returns {#default_price} or builds it from {Spree::Price.default_pricing}
    #
    # @return [Spree::Price, nil]
    # @see Spree::Price.default_pricing
    def default_price_or_build
      default_price ||
        prices.build(self.class.default_pricing)
    end

    # Select from {#prices} the one to be considered as the default
    #
    # This method works with the in-memory association, so non-persisted prices
    # are taken into account. Discarded prices are also considered.
    #
    # A price is a candidate to be considered as the default when it meets
    # {Spree::Variant.default_pricing} criteria. When more than one candidate is
    # found, non-persisted records take preference. When more than one persisted
    # candidate exists, the one most recently created is taken or, in case of
    # race condition, the one with higher id.
    #
    # @return [Spree::Price, nil]
    # @see Spree::Price.default_pricing
    def default_price
      candidates = discarded? ? (prices + prices.with_discarded).to_a.uniq : prices.to_a
      candidates.select do |price|
        price.
          attributes.
          values_at(
            *self.class.default_pricing.keys.map(&:to_s)
          ) == self.class.default_pricing.values
      end.min do |a, b|
        [b, a].map do |i|
          [
            i.created_at || Time.zone.now,
            i.id || Float::INFINITY
          ]
        end.reduce { |x, y| x <=> y }
      end
    end

    def has_default_price?
      default_price.present? && !default_price.discarded?
    end
  end
end
