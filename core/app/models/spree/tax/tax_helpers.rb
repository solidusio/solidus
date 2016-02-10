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
      def applicable_rates
        order_zone_tax_categories = order_rates.map(&:tax_category)
        default_rates_with_unmatched_tax_category = default_vat_rates.to_a.delete_if do |default_rate|
          order_zone_tax_categories.include?(default_rate.tax_category)
        end

        (order_rates + default_rates_with_unmatched_tax_category).uniq
      end

      def order_rates
        @order_rates ||= Spree::TaxRate.for_address(order.tax_address)
      end

      def default_vat_rates
        @default_vat_rates ||= Spree::TaxRate.for_address(Spree::Address.build_default)
      end
    end
  end
end
