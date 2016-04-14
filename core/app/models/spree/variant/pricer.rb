module Spree
  class Variant
    class Pricer
      class PriceNotFound < ActiveRecord::RecordNotFound; end

      def self.pricing_options_class
        Spree::Variant::Pricer::PricingOptions
      end

      attr_reader :variant
      def initialize(variant)
        @variant = variant
      end

      def price_for(price_options)
        price = variant.prices.where(price_options.desired_attributes).first
        raise PriceNotFound unless price
        price.money
      end
    end
  end
end
