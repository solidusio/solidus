module Spree
  module Tax
    module TaxHelpers
      private

      # Imagine with me this scenario:
      # You are living in Spain and you have a store which ships to France.
      # Spain is therefore your default tax rate.
      # When you ship to Spain, you want the Spanish rate to apply.
      # When you ship to France, you want the French rate to apply.
      #
      # Normally, Spree would notice that you have two potentially applicable
      # tax rates for one particular item.
      # When you ship to Spain, only the Spanish one will apply.
      # When you ship to France, you'll see a Spanish refund AND a French tax.
      # This little bit of code at the end stops the Spanish refund from appearing.
      #
      # For further discussion, see https://github.com/spree/spree/issues/4397 and https://github.com/spree/spree/issues/4327.
      def applicable_rates(order)
        order_zone_tax_categories = rates_for_order_zone(order).map(&:tax_category)
        default_rates_with_unmatched_tax_category = rates_for_default_zone.to_a.delete_if do |default_rate|
          order_zone_tax_categories.include?(default_rate.tax_category)
        end

        (rates_for_order_zone(order) + default_rates_with_unmatched_tax_category).uniq
      end

      def rates_for_order_zone(order)
        @rates_for_order_zone ||= Spree::TaxRate.for_zone(order_tax_zone(order))
      end

      def rates_for_default_zone
        @rates_for_default_zone ||= Spree::TaxRate.for_zone(Spree::Zone.default_tax)
      end

      def order_tax_zone(order)
        @order_tax_zone ||= order.tax_zone
      end

      def sum_of_included_tax_rates(item)
        rates_for_item(item).map(&:amount).sum
      end

      def rates_for_item(item)
        applicable_rates(item.order).select { |rate| rate.tax_category == item.tax_category }
      end
    end
  end
end
