# frozen_string_literal: true

require_dependency "spree/calculator"

module SolidusPromotions
  module Calculators
    # A calculator that applies tiered percentage-based discounts based on order item total thresholds.
    #
    # This calculator allows defining multiple discount tiers where each tier specifies a minimum
    # order item total threshold and the corresponding percentage discount to apply to the individual
    # item. The calculator selects the highest tier that the order qualifies for based on its item total.
    #
    # Unlike TieredFlatRate which applies a fixed amount, this calculator applies a percentage of the
    # item's amount. The tier thresholds are evaluated against the entire order's item total, but the
    # percentage discount is applied to the individual item (line item or shipment).
    #
    # If the order doesn't meet any tier threshold, the base percentage is used. The discount is only
    # applied if the currency matches the preferred currency.
    #
    # @example Use case: Volume-based percentage discounts
    #   # Higher discounts for larger orders
    #   calculator = TieredPercent.new(
    #     preferred_base_percent: 5,
    #     preferred_tiers: {
    #       100 => 10,  # 10% off when order total >= $100
    #       250 => 15,  # 15% off when order total >= $250
    #       500 => 20   # 20% off when order total >= $500
    #     },
    #     preferred_currency: 'USD'
    #   )
    #
    # @example Use case: Wholesale tier pricing
    #   # Different percentage discounts for different order sizes
    #   calculator = TieredPercent.new(
    #     preferred_base_percent: 0,
    #     preferred_tiers: {
    #       200 => 5,    # 5% wholesale discount at $200
    #       500 => 10,   # 10% wholesale discount at $500
    #       1000 => 15   # 15% wholesale discount at $1000
    #     },
    #     preferred_currency: 'USD'
    #   )
    class TieredPercent < Spree::Calculator
      include PromotionCalculator

      preference :base_percent, :decimal, default: Spree::ZERO
      preference :tiers, :hash, default: { 50 => 5 }
      preference :currency, :string, default: -> { Spree::Config[:currency] }

      before_validation :transform_preferred_tiers

      validates :preferred_base_percent, numericality: {
        greater_than_or_equal_to: Spree::ZERO,
        less_than_or_equal_to: 100
      }
      validate :preferred_tiers_content

      # Computes the tiered percentage discount for an item based on the order's item total.
      #
      # Evaluates the order's item total against all defined tiers and selects the highest
      # tier threshold that the order meets or exceeds. Returns a percentage of the item's
      # amount based on the matching tier, or the base percentage if no tier threshold is met.
      # Returns 0 if the currency doesn't match.
      #
      # @param object [Object] The object to calculate the discount for (e.g., LineItem, Shipment)
      #
      # @return [BigDecimal] The percentage-based discount amount, rounded to currency precision
      #
      # @example Computing discount with tier matching
      #   calculator = TieredPercent.new(
      #     preferred_base_percent: 5,
      #     preferred_tiers: { 100 => 10, 250 => 15 }
      #   )
      #   order.item_total # => 150.00
      #   line_item.amount # => 50.00
      #   calculator.compute_item(line_item) # => 5.00 (10% of $50, matches $100 tier)
      #
      # @example Computing discount below all tiers
      #   calculator = TieredPercent.new(
      #     preferred_base_percent: 5,
      #     preferred_tiers: { 100 => 10, 250 => 15 }
      #   )
      #   order.item_total # => 75.00
      #   line_item.amount # => 30.00
      #   calculator.compute_item(line_item) # => 1.50 (5% base percent of $30)
      #
      # @example Computing discount with currency mismatch
      #   calculator = TieredPercent.new(
      #     preferred_currency: 'USD',
      #     preferred_tiers: { 100 => 10 }
      #   )
      #   order.currency # => 'EUR'
      #   calculator.compute_item(line_item) # => 0
      def compute_item(object)
        order = object.order

        _base, percent = preferred_tiers.sort.reverse.detect do |value, _|
          order.item_total >= value
        end

        if preferred_currency.casecmp(order.currency).zero?
          round_to_currency(object.amount * (percent || preferred_base_percent) / 100, preferred_currency)
        else
          Spree::ZERO
        end
      end
      alias_method :compute_shipment, :compute_item
      alias_method :compute_line_item, :compute_item

      private

      # Transforms preferred_tiers keys and values to BigDecimal for consistent calculations.
      #
      # Converts all tier threshold keys and percentage values from strings or other numeric
      # types to BigDecimal to ensure precision in monetary calculations.
      def transform_preferred_tiers
        return unless preferred_tiers.is_a?(Hash)

        preferred_tiers.transform_keys! { |key| key.to_s.to_d }
        preferred_tiers.transform_values! { |value| value.to_s.to_d }
      end

      # Validates that preferred_tiers is properly formatted with valid thresholds and percentages.
      #
      # Ensures:
      # - Tiers is a hash
      # - All keys (thresholds) are positive numbers
      # - All values (percentages) are between 0 and 100
      def preferred_tiers_content
        if preferred_tiers.is_a? Hash
          unless preferred_tiers.keys.all? { |key| key.is_a?(Numeric) && key > 0 }
            errors.add(:base, :keys_should_be_positive_number)
          end
          unless preferred_tiers.values.all? { |key| key.is_a?(Numeric) && key >= 0 && key <= 100 }
            errors.add(:base, :values_should_be_percent)
          end
        else
          errors.add(:preferred_tiers, :should_be_hash)
        end
      end
    end
  end
end
