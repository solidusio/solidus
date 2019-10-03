# frozen_string_literal: true

module Solidus
  module Tax
    # Used to build shipping rate taxes
    class ShippingRateTaxer
      # Build shipping rate taxes for a shipping rate
      # Modifies the passed-in shipping rate with associated shipping rate taxes.
      # @param [Solidus::ShippingRate] shipping_rate The shipping rate to add taxes to.
      #   This parameter will be modified.
      # @return [Solidus::ShippingRate] The shipping rate with associated tax objects
      def tax(shipping_rate)
        taxes = Solidus::Config.shipping_rate_tax_calculator_class.new(shipping_rate.order).calculate(shipping_rate)
        taxes.each do |tax|
          shipping_rate.taxes.build(
            amount: tax.amount,
            tax_rate: tax.tax_rate
          )
        end
        shipping_rate
      end
    end
  end
end
