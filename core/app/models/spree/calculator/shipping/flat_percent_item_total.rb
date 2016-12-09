require_dependency 'spree/shipping_calculator'

module Spree
  module Calculator::Shipping
    class FlatPercentItemTotal < ShippingCalculator
      preference :flat_percent, :decimal, default: 0

      def compute_package(package)
        compute_from_price(total(package.contents))
      end

      def compute_from_price(price)
        value = price * BigDecimal(preferred_flat_percent.to_s) / 100.0
        value.round(2)
      end
    end
  end
end
