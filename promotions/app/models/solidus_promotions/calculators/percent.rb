# frozen_string_literal: true

require_dependency "spree/calculator"

module SolidusPromotions
  module Calculators
    # A calculator that applies a percentage-based discount.
    #
    # This calculator computes the discount as a percentage of the item's discountable amount,
    # rounded to the appropriate currency precision.
    #
    # @example
    #   calculator = Percent.new(preferred_percent: 15)
    #   # Line item with discountable_amount of $100
    #   calculator.compute_item(line_item) # => 15.00 (15% of $100)
    class Percent < Spree::Calculator
      include PromotionCalculator

      preference :percent, :decimal, default: 0

      # Computes the percentage-based discount for an item.
      #
      # Calculates the discount by applying the preferred percentage to the item's
      # discountable amount, then rounds the result to the appropriate precision
      # for the order's currency.
      #
      # @param object [Object] The object to calculate the discount for (e.g., LineItem, Shipment, ShippingRate)
      #
      # @return [BigDecimal] The discount amount, rounded to the order's currency precision
      #
      # @example Computing a 20% discount on a $50 line item
      #   calculator = Percent.new(preferred_percent: 20)
      #   line_item.discountable_amount # => 50.00
      #   calculator.compute_item(line_item) # => 10.00
      #
      # @example Computing a 15% discount on a shipment
      #   calculator = Percent.new(preferred_percent: 15)
      #   shipment.discountable_amount # => 25.00
      #   calculator.compute_item(shipment) # => 3.75
      def compute_item(object)
        round_to_currency(object.discountable_amount * preferred_percent / 100, object.order.currency)
      end
      alias_method :compute_line_item, :compute_item
      alias_method :compute_shipment, :compute_item
      alias_method :compute_shipping_rate, :compute_item
    end
  end
end
