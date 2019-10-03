# frozen_string_literal: true

require_dependency 'solidus/calculator'
require_dependency 'solidus/shipping_calculator'

module Solidus
  module Calculator::Shipping
    class FlatRate < ShippingCalculator
      preference :amount, :decimal, default: 0
      preference :currency, :string, default: ->{ Solidus::Config[:currency] }

      def compute_package(_package)
        preferred_amount
      end
    end
  end
end
