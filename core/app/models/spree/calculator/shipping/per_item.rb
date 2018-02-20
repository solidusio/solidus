# frozen_string_literal: true

require_dependency 'spree/calculator'
require_dependency 'spree/shipping_calculator'

module Spree
  module Calculator::Shipping
    class PerItem < ShippingCalculator
      preference :amount, :decimal, default: 0
      preference :currency, :string, default: ->{ Spree::Config[:currency] }

      def compute_package(package)
        compute_from_quantity(package.contents.sum(&:quantity))
      end

      def compute_from_quantity(quantity)
        preferred_amount * quantity
      end
    end
  end
end
