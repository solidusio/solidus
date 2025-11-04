# frozen_string_literal: true

require_dependency "spree/calculator"

module SolidusPromotions
  module Calculators
    # A calculator that applies tiered percentage discounts based on the total quantity of eligible items.
    #
    # This calculator defines discount tiers based on the combined quantity of all eligible line items
    # in an order (not their monetary value). Each tier specifies a minimum quantity threshold and the
    # corresponding percentage discount to apply. The calculator selects the highest tier that the
    # order's eligible item quantity meets or exceeds.
    #
    # The tier thresholds are evaluated against the total quantity of eligible line items, but the
    # percentage discount is applied to each individual item's discountable amount. This makes it
    # ideal for "buy more, save more" promotions based on item count rather than order value.
    #
    # If the total eligible quantity doesn't meet any tier threshold, the base percentage is used.
    # The discount is only applied if the currency matches the preferred currency.
    #
    # @example Use case: Bulk quantity discounts
    #   # Buy 10+ items get 5% off, 25+ get 10% off, 50+ get 15% off
    #   calculator = TieredPercentOnEligibleItemQuantity.new(
    #     preferred_base_percent: 0,
    #     preferred_tiers: {
    #       10 => 5,   # 5% off when total eligible quantity >= 10
    #       25 => 10,  # 10% off when total eligible quantity >= 25
    #       50 => 15   # 15% off when total eligible quantity >= 50
    #     },
    #     preferred_currency: 'USD'
    #   )
    #
    # @example Use case: Multi-item bundle promotions
    #   # Encourage buying multiple items from a category
    #   calculator = TieredPercentOnEligibleItemQuantity.new(
    #     preferred_base_percent: 0,
    #     preferred_tiers: {
    #       3 => 10,   # 10% off when buying 3+ eligible items
    #       5 => 15,   # 15% off when buying 5+ eligible items
    #       10 => 20   # 20% off when buying 10+ eligible items
    #     },
    #     preferred_currency: 'USD'
    #   )
    class TieredPercentOnEligibleItemQuantity < Spree::Calculator
      include PromotionCalculator

      preference :base_percent, :decimal, default: Spree::ZERO
      preference :tiers, :hash, default: { 10 => 5 }
      preference :currency, :string, default: -> { Spree::Config[:currency] }

      before_validation :transform_preferred_tiers

      # Computes the tiered percentage discount for an item based on total eligible item quantity.
      #
      # Evaluates the total quantity of all eligible line items in the order against all defined
      # tiers and selects the highest tier threshold that is met or exceeded. Returns a percentage
      # of the item's discountable amount based on the matching tier, or the base percentage if no
      # tier threshold is met. Returns 0 if the currency doesn't match.
      #
      # @param item [Object] The object to calculate the discount for (e.g., LineItem, Shipment, ShippingRate)
      #
      # @return [BigDecimal] The percentage-based discount amount, rounded to currency precision
      #
      # @example Computing discount with tier matching
      #   calculator = TieredPercentOnEligibleItemQuantity.new(
      #     preferred_base_percent: 0,
      #     preferred_tiers: { 10 => 10, 25 => 15 }
      #   )
      #   # Order has 3 eligible line items with quantities: 5, 6, 4 (total: 15)
      #   line_item.discountable_amount # => 50.00
      #   calculator.compute_item(line_item) # => 5.00 (10% of $50, matches quantity tier of 10)
      #
      # @example Computing discount below all tiers
      #   calculator = TieredPercentOnEligibleItemQuantity.new(
      #     preferred_base_percent: 5,
      #     preferred_tiers: { 10 => 10, 25 => 15 }
      #   )
      #   # Order has 2 eligible line items with quantities: 3, 4 (total: 7)
      #   line_item.discountable_amount # => 30.00
      #   calculator.compute_item(line_item) # => 1.50 (5% base percent of $30)
      #
      # @example Computing discount with currency mismatch
      #   calculator = TieredPercentOnEligibleItemQuantity.new(
      #     preferred_currency: 'USD',
      #     preferred_tiers: { 10 => 10 }
      #   )
      #   order.currency # => 'EUR'
      #   calculator.compute_item(line_item) # => 0
      def compute_item(item)
        order = item.order

        _base, percent = preferred_tiers.sort.reverse.detect do |value, _|
          eligible_line_items_quantity_total(order) >= value
        end
        if preferred_currency.casecmp(order.currency).zero?
          round_to_currency(item.discountable_amount * (percent || preferred_base_percent) / 100, preferred_currency)
        else
          Spree::ZERO
        end
      end
      alias_method :compute_shipment, :compute_item
      alias_method :compute_shipping_rate, :compute_item
      alias_method :compute_line_item, :compute_item

      private

      # Transforms preferred_tiers keys to integers and values to BigDecimal.
      #
      # Converts tier threshold keys (item quantities) to integers and percentage values
      # to BigDecimal for consistent calculations.
      def transform_preferred_tiers
        preferred_tiers.transform_keys!(&:to_i)
        preferred_tiers.transform_values! { |value| value.to_s.to_d }
      end

      # Calculates the total quantity of all eligible line items in the order.
      #
      # @param order [Spree::Order] The order to calculate eligible quantity for
      # @return [Integer] The sum of quantities for all applicable line items
      def eligible_line_items_quantity_total(order)
        calculable.applicable_line_items(order).sum(&:quantity)
      end
    end
  end
end
