# frozen_string_literal: true

require_dependency "spree/calculator"

module SolidusPromotions
  module Calculators
    class Percent < Spree::Calculator
      include PromotionCalculator

      preference :percent, :decimal, default: 0

      def compute_item(item)
        compute_with_currency(item, item.order.currency)
      end
      alias_method :compute_line_item, :compute_item
      alias_method :compute_shipment, :compute_item

      def compute_price(price, _options = {})
        compute_with_currency(price, price.currency)
      end

      private

      def compute_with_currency(item, currency)
        currency_exponent = ::Money::Currency.find(currency).exponent
        (item.discountable_amount * preferred_percent / 100).round(currency_exponent)
      end
    end
  end
end
