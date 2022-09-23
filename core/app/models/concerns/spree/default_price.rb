# frozen_string_literal: true

module Spree
  module DefaultPrice
    extend ActiveSupport::Concern

    included do
      delegate :display_price, :display_amount, :price, to: :default_price, allow_nil: true
      delegate :price=, to: :default_price_or_build

      # @see Spree::Variant::PricingOptions.default_price_attributes
      def self.default_price_attributes
        Spree::Config.default_pricing_options.desired_attributes
      end
    end

    # Returns `#prices` prioritized for being considered as default price
    #
    # @return [Array<Spree::Price>]
    def currently_valid_prices
      prices.sort_by do |price|
        [
          price.country_iso.nil? ? 0 : 1,
          price.updated_at || Time.zone.now,
          price.id || Float::INFINITY,
        ]
      end.reverse
    end

    # Returns {#default_price} or builds it from {Spree::Variant.default_price_attributes}
    #
    # @return [Spree::Price, nil]
    # @see Spree::Variant.default_price_attributes
    def default_price_or_build
      default_price ||
        prices.build(self.class.default_price_attributes)
    end

    # Select from {#prices} the one to be considered as the default
    #
    # This method works with the in-memory association, so non-persisted prices
    # are taken into account.
    #
    # A price is a candidate to be considered as the default when it meets
    # {Spree::Variant.default_price_attributes} criteria. When more than one candidate is
    # found, non-persisted records take preference. When more than one persisted
    # candidate exists, the one most recently updated is taken or, in case of
    # race condition, the one with higher id.
    #
    # @return [Spree::Price, nil]
    # @see Spree::Variant.default_price_attributes
    def default_price
      prioritized_default(
        prices_meeting_criteria_to_be_default(
          prices
        )
      )
    end

    def has_default_price?
      default_price.present? && !default_price.discarded?
    end

    private

    def prices_meeting_criteria_to_be_default(prices)
      criteria = self.class.default_price_attributes.transform_keys(&:to_s)
      prices.select do |price|
        contender = price.attributes.slice(*criteria.keys)
        criteria == contender
      end
    end

    def prioritized_default(prices)
      prices.min do |prev, succ|
        contender_one, contender_two = [succ, prev].map do |item|
          [
            item.updated_at || Time.zone.now,
            item.id || Float::INFINITY
          ]
        end
        contender_one <=> contender_two
      end
    end
  end
end
