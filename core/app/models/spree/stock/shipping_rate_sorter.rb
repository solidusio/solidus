module Spree
  module Stock
    class ShippingRateSorter
      attr_reader :shipping_rates

      def initialize(shipping_rates)
        @shipping_rates = shipping_rates
      end

      def sort
        shipping_rates.sort_by(&:cost)
      end
    end
  end
end
