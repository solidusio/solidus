# frozen_string_literal: true

module Spree
  module Stock
    class ShippingRateFilter
      attr_reader :shipping_rates, :frontend_only

      def initialize(shipping_rates, frontend_only:)
        @shipping_rates = shipping_rates
        @frontend_only = frontend_only
      end

      def filter
        return shipping_rates unless frontend_only

        shipping_rates.select { |rate| rate.shipping_method.available_to_users? }
      end
    end
  end
end
