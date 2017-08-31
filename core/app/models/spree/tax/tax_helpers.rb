module Spree
  module Tax
    module TaxHelpers
      private

      def applicable_rates(order)
        @rates_for_order ||= Spree::TaxRate.for_address(order.tax_address)
      end

      def sum_of_included_tax_rates(item)
        rates_for_item(item).map(&:amount).sum
      end

      def rates_for_item(item)
        applicable_rates(item.order).select do |rate|
          rate.tax_categories.map(&:id).include?(item.tax_category_id)
        end
      end
    end
  end
end
