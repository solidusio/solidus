module Spree
  module Tax
    # Used to build shipping rate taxes
    class ShippingRateTaxer
      include TaxHelpers

      # Build shipping rate taxes for a shipping rate
      # Modifies the passed-in shipping rate with associated shipping rate taxes.
      # @param [Spree::ShippingRate] shipping_rate The shipping rate to add taxes to.
      #   This parameter will be modified.
      # @return [Spree::ShippingRate] The shipping rate with associated tax objects
      def tax(shipping_rate)
        tax_rates_for_shipping_rate(shipping_rate).each do |tax_rate|
          shipping_rate.taxes.build(
            amount: tax_rate.compute_amount(shipping_rate),
            tax_rate: tax_rate
          )
        end
        shipping_rate
      end

      private

      def tax_rates_for_shipping_rate(shipping_rate)
        applicable_rates(shipping_rate.order).select do |tax_rate|
          tax_rate.tax_category == shipping_rate.tax_category
        end
      end
    end
  end
end
