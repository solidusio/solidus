require_dependency 'spree/shipping_calculator'

module Spree
  module Calculator::Shipping
    class FlatRate < ShippingCalculator
      preference :amount, :decimal, default: 0
      preference :currency, :string, default: ->{ Spree::Config[:currency] }

      def compute_package(package)
        if package.order && preferred_currency.casecmp(package.order.currency).zero?
          preferred_amount
        else
          BigDecimal.new(0)
        end
      end
    end
  end
end
