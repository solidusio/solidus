module Spree
  module Tax
    module TaxHelpers
      private

      def rates_for_order_zone
        @rates_for_order_zone ||= Spree::TaxRate.for_zone(order_tax_zone)
      end

      def rates_for_default_zone
        @rates_for_default_zone ||= Spree::TaxRate.for_zone(default_tax_zone)
      end

      def order_tax_zone
        @order_tax_zone ||= order.tax_zone
      end

      def default_tax_zone
        # Memoizing values that are potentially `false` can not use the `||=` shorthand
        @default_tax_zone.nil? ? Spree::Zone.default_tax.presence : @default_tax_zone
      end

      def outside_default_vat_zone?
        # Memoizing booleans can not use the `||=` shorthand
        if @outside_default_vat_zone.nil?
          @outside_default_vat_zone = default_tax_zone && !default_tax_zone.contains?(order_tax_zone)
        else
          @outside_default_vat_zone
        end
      end
    end
  end
end
