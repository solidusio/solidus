# frozen_string_literal: true

require_dependency "spree/calculator"

module SolidusPromotions
  module Calculators
    # A calculator that applies a flat rate discount amount.
    #
    # This calculator returns a fixed discount amount if the item's order currency
    # matches the preferred currency, otherwise it returns zero.
    class FlatRate < Spree::Calculator
      include PromotionCalculator

      preference :amount, :decimal, default: Spree::ZERO
      preference :currency, :string, default: -> { Spree::Config[:currency] }

      # Computes the discount amount for an item.
      #
      # Returns the preferred amount if the item's order currency matches the
      # preferred currency, otherwise returns 0.
      #
      # @param item [Object] The item to calculate the discount for (e.g., LineItem, Shipment, ShippingRate)
      #
      # @return [BigDecimal] The discount amount (preferred_amount if currency matches, 0 otherwise)
      #
      # @example Computing discount for a line item with matching currency
      #   calculator = FlatRate.new(preferred_amount: 10, preferred_currency: 'USD')
      #   line_item.order.currency # => 'USD'
      #   calculator.compute_item(line_item) # => 10.0
      #
      # @example Computing discount for a line item with non-matching currency
      #   calculator = FlatRate.new(preferred_amount: 10, preferred_currency: 'USD')
      #   line_item.order.currency # => 'EUR'
      #   calculator.compute_item(line_item) # => 0
      def compute_item(item)
        currency = item.order.currency
        if item && preferred_currency.casecmp(currency).zero?
          preferred_amount
        else
          Spree::ZERO
        end
      end
      alias_method :compute_line_item, :compute_item
      alias_method :compute_shipment, :compute_item
      alias_method :compute_shipping_rate, :compute_item
    end
  end
end
