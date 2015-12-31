require_dependency 'solidus/shipping_calculator'

module Solidus
  module Calculator::Shipping
    class FlatRate < ShippingCalculator
      preference :amount, :decimal, default: 0
      preference :currency, :string, default: ->{ Solidus::Config[:currency] }

      def self.description
        Solidus.t(:shipping_flat_rate_per_order)
      end

      def compute_package(package)
        self.preferred_amount
      end
    end
  end
end
