module Spree
  class Variant
    class Pricer
      class PricingOptions
        DEFAULT_PRICE_ATTRIBUTES = { currency: Spree::Config.currency, is_default: true }.freeze

        def self.from_order(order)
          new(currency: order.currency)
        end

        attr_reader :desired_attributes

        def initialize(desired_attributes = {})
          @desired_attributes = DEFAULT_PRICE_ATTRIBUTES.merge(desired_attributes)
        end

        def cache_key
          desired_attributes.values.map(&:to_s).join("/")
        end
      end
    end
  end
end
