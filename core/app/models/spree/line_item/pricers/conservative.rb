module Spree
  class LineItem
    module Pricers
      class Conservative
        class VariantMissing < StandardError; end
        class CurrencyMissing < StandardError; end

        attr_reader :line_item

        def initialize(line_item)
          @line_item = line_item
        end

        def price
          raise CurrencyMissing if line_item.currency.blank?
          return in_line_item_currency(line_item.price) if line_item.price

          raise VariantMissing if line_item.variant.blank?
          in_line_item_currency(line_item.variant.amount_in(line_item.currency))
        end

        private

        def in_line_item_currency(amount)
          Spree::Money.new(amount, currency: line_item.currency)
        end
      end
    end
  end
end
