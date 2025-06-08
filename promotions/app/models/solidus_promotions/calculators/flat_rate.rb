# frozen_string_literal: true

require_dependency "spree/calculator"

module SolidusPromotions
  module Calculators
    class FlatRate < Spree::Calculator
      include PromotionCalculator

      preference :amount, :decimal, default: 0
      preference :currency, :string, default: -> { Spree::Config[:currency] }

      def compute_item(item)
        currency = item.order.currency
        if item && preferred_currency.casecmp(currency).zero?
          preferred_amount
        else
          0
        end
      end
      alias_method :compute_line_item, :compute_item
      alias_method :compute_shipment, :compute_item

      def compute_price(price, options = {})
        order = options[:order]
        return preferred_amount unless order
        return Spree::ZERO if order.currency != preferred_currency
        line_item_with_variant = order.line_items.detect { _1.variant == price.variant }
        [Spree::ZERO, preferred_amount - line_item_with_variant.amount].max
      end
    end
  end
end
