# frozen_string_literal: true

require_dependency 'solidus/calculator'
require_dependency 'solidus/shipping_calculator'

module Solidus
  module Calculator::Shipping
    class PerItem < ShippingCalculator
      preference :amount, :decimal, default: 0
      preference :currency, :string, default: ->{ Solidus::Config[:currency] }

      def compute_package(package)
        compute_from_quantity(package.contents.sum(&:quantity))
      end

      def compute_from_quantity(quantity)
        preferred_amount * quantity
      end
    end
  end
end
