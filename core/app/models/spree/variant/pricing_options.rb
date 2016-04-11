module Spree
  class Variant
    class PricingOptions
      def self.default_price_attributes
        { currency: Spree::Config.currency }
      end

      def self.from_line_item(line_item)
        new(currency: line_item.order.currency)
      end

      attr_reader :desired_attributes

      def initialize(desired_attributes = {})
        @desired_attributes = self.class.default_price_attributes.merge(desired_attributes)
      end

      def currency
        desired_attributes[:currency]
      end

      def cache_key
        desired_attributes.values.map(&:to_s).join("/")
      end
    end
  end
end
