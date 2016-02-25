module Spree
  module Tax
    class ShippingRateTaxer
      include TaxHelpers

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
