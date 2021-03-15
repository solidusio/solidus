# frozen_string_literal: true

module Spree
  module DefaultPrice
    extend ActiveSupport::Concern

    included do
      # TODO: Treat as a regular method to avoid in-memory inconsistencies with
      # `prices`. e.g.:
      #
      # ```
      # Variant.new(price: 25).prices.any? # => false
      # ```
      has_one :default_price,
        -> { with_discarded.currently_valid.with_default_attributes },
        class_name: 'Spree::Price',
        inverse_of: :variant,
        dependent: :destroy,
        autosave: true

      def self.default_pricing
        Spree::Config.default_pricing_options.desired_attributes
      end
    end

    def find_or_build_default_price
      default_price ||
        default_price_from_memory ||
        build_default_price(self.class.default_pricing)
    end

    delegate :display_price, :display_amount, :price, to: :find_or_build_default_price
    delegate :price=, to: :find_or_build_default_price

    def has_default_price?
      default_price.present? && !default_price.discarded?
    end

    private

    # TODO: Remove when {Spree::Price.default_price} is no longer an
    # association.
    def default_price_from_memory
      prices.to_a.select(&:new_record?).find do |price|
        price.
          attributes.
          values_at(
            *self.class.default_pricing.keys.map(&:to_s)
          ) == self.class.default_pricing.values
      end
    end
  end
end
