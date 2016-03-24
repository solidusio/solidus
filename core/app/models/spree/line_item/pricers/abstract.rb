module Spree
  class LineItem
    module Pricers
      class Abstract
        class VariantMissing < StandardError; end
        class CurrencyMissing < StandardError; end

        attr_reader :line_item

        def initialize(line_item)
          @line_item = line_item
        end

        def price
          raise NotImplementedError, "Please implement '#price' in your pricer: #{self.class.name}"
        end

        private

        def in_line_item_currency(amount)
          Spree::Money.new(amount, currency: line_item.currency)
        end
      end
    end
  end
end
