module Spree
  module Tax
    class ItemAdjuster
      attr_reader :item, :order

      def initialize(item)
        @item = item
        @order = @item.order
      end

      def adjust!
        Spree::TaxRate.adjust(order.tax_zone, [item])
      end
    end
  end
end
