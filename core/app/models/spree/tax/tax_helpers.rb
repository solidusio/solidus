module Spree
  module Tax
    module TaxHelpers
      private

      def rates_for_order_zone
        @rates_for_order_zone ||= Spree::TaxRate.match(order_tax_zone)
      end

      def order_tax_zone
        @order_tax_zone ||= order.tax_zone
      end
    end
  end
end
