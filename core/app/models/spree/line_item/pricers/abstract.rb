module Spree
  class LineItem
    # Pricers for line items expose `#price`, return a `Spree::Money` object,
    # and are used to choose or calculate the correct price for a line item.
    # Ideally, they are idempotent, that is: When run on the same line item, they will return
    # the same price.
    #
    module Pricers
      # The `Abstract` pricer is here for other pricers to inherit from. It defines the common
      # interface for pricers, as well as two practical errors, `VariantMissing` and
      # `CurrencyMissing`.
      #
      # @attr [Spree::LineItem] The line item to calculate or choose a price for
      class Abstract
        class VariantMissing < StandardError; end
        class CurrencyMissing < StandardError; end

        attr_reader :line_item

        def initialize(line_item)
          @line_item = line_item
        end

        # Returns the calculated or chosen price
        #
        # @return [Spree::Money] a `Spree::Money` object representing line item's price
        def price
          raise NotImplementedError, "Please implement '#price' in your pricer: #{self.class.name}"
        end

        private

        # This helper method converts an amount into a Spree::Money object with the given line
        # item's currency, and will be needed for most pricers.
        #
        def in_line_item_currency(amount)
          Spree::Money.new(amount, currency: line_item.currency)
        end
      end
    end
  end
end
