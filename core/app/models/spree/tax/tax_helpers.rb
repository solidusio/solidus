module Spree
  module Tax
    module TaxHelpers
      private

      def rates_for_order(order)
        @rates_for_order ||= Spree::TaxRate.for_address(order.tax_address)
      end

      def sum_of_included_tax_rates(item)
        rates_for_item(item).map(&:amount).sum
      end

      def rates_for_item(item)
        rates_for_order(item.order).select { |rate| rate.tax_category == item.tax_category }
      end
    end
  end
end
