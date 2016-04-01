module Spree
  class LineItem
    module Pricers
      # A pricer that returns a line items price if it has one, otherwise chooses a fitting
      # one in the line item's currency.
      # This pricer's behaviour mimicks pricing behaviour in Solidus 1.2 and earlier (Spree 2.4 and
      # earlier). The standard pricer in Solidus 1.3 and above will choose the price depending on
      # the country, and will not necessarily be as conservative about a line item's current price.
      #
      # @note If you use price modifiers, you need to use this conservative pricer.
      #
      class Conservative < Abstract
        # The new price of the line item.
        #
        # @return Spree::Money
        #
        def price
          raise CurrencyMissing if line_item.currency.blank?
          return in_line_item_currency(line_item.price) if line_item.price

          raise VariantMissing if line_item.variant.blank?
          in_line_item_currency(line_item.variant.amount_in(line_item.currency))
        end
      end
    end
  end
end
