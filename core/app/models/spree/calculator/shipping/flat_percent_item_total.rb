# frozen_string_literal: true

require_dependency 'spree/calculator'
require_dependency 'spree/shipping_calculator'

module Spree
  module Calculator::Shipping
    class FlatPercentItemTotal < ShippingCalculator
      preference :flat_percent, :decimal, default: 0

      def compute_package(package)
        value = compute_from_price(total(package.contents))
        preferred_currency = package.order.currency
        currency_exponent = ::Money::Currency.find(preferred_currency).exponent
        value.round(currency_exponent)
      end

      def compute_from_price(price)
        price * BigDecimal(preferred_flat_percent.to_s) / 100.0
      end
    end
  end
end
