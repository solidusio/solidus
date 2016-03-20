module Spree
  class LineItem
    module Pricers
      # This class implements an extension point previously defined on Spree::LineItem
      # for customizing pricing from extensions. This extension point is currently used
      # in the following Spree extensions:
      #
      # * https://github.com/godaddy/spree_product_sale
      # * https://github.com/v-may/spree_simple_sales
      #
      # @attr_reader [Spree::LineItem] line_item The line item to find a price for
      # @attr_reader [Hash] options Options that would modify the price, such as { gift_wrap: true }
      # @deprecated The extension point, as far as I can overview, needs the following to work:
      #
      #   - `*_price_modifier_amount_in` methods defined on the variant
      #   - Fitting `*` methods on `Spree::LineItem`
      #   - The Line Item to accept those methods as attributes
      #
      #   That's a rather complex way of customizing pricing, maybe write a pricer instead.
      class PriceModifier < Abstract
        attr_reader :options
        delegate :currency, :variant, to: :line_item

        def initialize(line_item, options = {})
          @line_item = line_item
          @options = options
        end

        # @return [Spree::Money] New price for a line item
        def price
          raise VariantMissing if variant.blank?
          raise CurrencyMissing if currency.blank?
          in_line_item_currency(
            variant.price_in(currency).amount + variant.price_modifier_amount_in(currency, options)
          )
        end
      end
    end
  end
end
