module Spree
  class Variant
    class Pricer
      def self.pricing_options_class
        Spree::Variant::Pricer::PricingOptions
      end

      attr_reader :variant
      def initialize(variant)
        @variant = variant
      end

      def price_for(price_options)
        variant.prices.where(price_options.desired_attributes).first.try!(:money)
      end
    end
  end
end
