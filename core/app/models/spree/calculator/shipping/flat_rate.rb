# frozen_string_literal: true

require_dependency 'spree/calculator'
require_dependency 'spree/shipping_calculator'

module Spree
  module Calculator::Shipping
    class FlatRate < ShippingCalculator
      preference :amount, :decimal, default: 0
      preference :currency, :string, default: ->{ Spree::Config[:currency] }

      def compute_package(_package)
        preferred_amount
      end
    end
  end
end
