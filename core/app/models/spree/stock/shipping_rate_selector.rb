# frozen_string_literal: true

module Spree
  module Stock
    class ShippingRateSelector
      attr_reader :shipping_rates

      def initialize(shipping_rates)
        @shipping_rates = shipping_rates
      end

      def find_default
        shipping_rates.min_by(&:cost)
      end
    end
  end
end
