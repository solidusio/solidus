module Spree
  module Prices
    # Set price, cost_price and currency for a line item. This class does
    # all the things from Spree::LineItem related to actually setting the price.
    # Some of these things are terribly evil and bad, especially the price modifying
    # options.
    class LegacyLineItemPricer
      class VariantRequired < StandardError; end
      class << self
        # Modify a line item's prices. If there's no price set or price modifying
        # options present, change the price to whatever the variant returns. If
        # the line item already has a price and there is no price modifying options
        # present, return the item unmodified.
        # @param [Spree::LineItem] line_item The line item to be modified
        # @param [Hash] options Arbitrary options for pricing the line item
        #    If the key `:currency` is set, the line item will be prices in that currency.
        def set_price_for(line_item, options = {})
          raise VariantRequired if line_item.variant.blank?

          # If the legacy method #copy_price has been overridden, handle that gracefully
          return handle_copy_price_override(line_item) if line_item.respond_to?(:copy_price)

          if price_modifiying_options(line_item.variant, options).present?
            line_item.currency = line_item_currency(line_item, options)
            line_item.price = line_item_price_with_modifiers(line_item, options)
          else
            line_item.currency ||= line_item_currency(line_item, options)
            line_item.price ||= line_item_price(line_item)
          end

          line_item
        end

        protected

        def line_item_price(line_item)
          line_item.variant.price_in(line_item.currency).amount
        end

        def line_item_currency(line_item, options)
          options[:currency] || line_item.order.currency
        end

        def line_item_price_with_modifiers(line_item, options)
          line_item_price(line_item) + line_item.variant.price_modifier_amount_in(line_item.currency, options)
        end

        def price_modifiying_options(variant, options)
          options.select do |k, _v|
            modifier_methods = [k.to_s + "_price_modifier_amount", k.to_s + "_price_modifier_amount_in"].map(&:to_sym)
            modifier_methods & variant.methods
          end
        end

        def handle_copy_price_override(line_item)
          line_item.send(:copy_price)
          ActiveSupport::Deprecation.warn(
            'You have overridden Spree::LineItem#copy_price.' \
            'Please configure a custom Line Item Pricer class for your app.',
            caller
          )
        end
      end
    end
  end
end
