module Spree
  class LineItem
    module Pricers
      class Conservative < Abstract
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
