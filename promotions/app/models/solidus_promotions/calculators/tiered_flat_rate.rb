# frozen_string_literal: true

require_dependency "spree/calculator"

module SolidusPromotions
  module Calculators
    # A calculator that applies tiered flat-rate discounts based on discountable amount thresholds.
    #
    # This calculator allows defining multiple discount tiers where each tier specifies a minimum
    # discountable amount threshold and the corresponding discount amount to apply. The calculator
    # selects the highest tier that the item qualifies for based on its discountable amount.
    #
    # If the item doesn't meet any tier threshold, the base amount is used. The discount is only
    # applied if the currency matches the preferred currency.
    #
    # @example Use case: Volume-based shipping discounts
    #   # Free shipping on orders over $100, $5 off on orders over $50
    #   calculator = TieredFlatRate.new(
    #     preferred_base_amount: 0,
    #     preferred_tiers: {
    #       50 => 5,   # $5 discount when amount >= $50
    #       100 => 15  # $15 discount when amount >= $100
    #     },
    #     preferred_currency: 'USD'
    #   )
    #
    # @example Use case: Bulk purchase incentives
    #   # Tiered discounts for line items based on total line value
    #   calculator = TieredFlatRate.new(
    #     preferred_base_amount: 2,
    #     preferred_tiers: {
    #       25 => 5,    # $5 off when line total >= $25
    #       50 => 12,   # $12 off when line total >= $50
    #       100 => 30   # $30 off when line total >= $100
    #     },
    #     preferred_currency: 'USD'
    #   )
    class TieredFlatRate < Spree::Calculator
      include PromotionCalculator

      preference :base_amount, :decimal, default: Spree::ZERO
      preference :tiers, :hash, default: { 10 => 10 }
      preference :currency, :string, default: -> { Spree::Config[:currency] }

      before_validation :transform_preferred_tiers

      validate :preferred_tiers_content

      # Computes the tiered flat-rate discount for an item.
      #
      # Evaluates the item's discountable amount against all defined tiers and selects
      # the highest tier threshold that the item meets or exceeds. Returns the discount
      # amount associated with that tier, or the base amount if no tier threshold is met.
      # Returns 0 if the currency doesn't match.
      #
      # @param object [Object] The object to calculate the discount for (e.g., LineItem, Shipment)
      #
      # @return [BigDecimal] The discount amount from the matching tier, base amount, or 0
      #
      # @example Computing discount with tier matching
      #   calculator = TieredFlatRate.new(
      #     preferred_base_amount: 2,
      #     preferred_tiers: { 25 => 5, 50 => 10, 100 => 20 }
      #   )
      #   line_item.discountable_amount # => 75.00
      #   calculator.compute_item(line_item) # => 10.00 (matches $50 tier)
      #
      # @example Computing discount below all tiers
      #   calculator = TieredFlatRate.new(
      #     preferred_base_amount: 2,
      #     preferred_tiers: { 25 => 5, 50 => 10 }
      #   )
      #   line_item.discountable_amount # => 15.00
      #   calculator.compute_item(line_item) # => 2.00 (base amount)
      #
      # @example Computing discount with currency mismatch
      #   calculator = TieredFlatRate.new(
      #     preferred_currency: 'USD',
      #     preferred_tiers: { 50 => 10 }
      #   )
      #   line_item.currency # => 'EUR'
      #   calculator.compute_item(line_item) # => 0
      def compute_item(object)
        _base, amount = preferred_tiers.sort.reverse.detect do |value, _|
          object.discountable_amount >= value
        end

        if preferred_currency.casecmp(object.currency).zero?
          amount || preferred_base_amount
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

      # Validates that preferred_tiers is a hash with positive numeric keys.
      #
      # Ensures the tiers preference is properly formatted for tier-based calculations.
      def preferred_tiers_content
        if preferred_tiers.is_a? Hash
          unless preferred_tiers.keys.all? { |key| key.is_a?(Numeric) && key > 0 }
            errors.add(:base, :keys_should_be_positive_number)
          end
        else
          errors.add(:preferred_tiers, :should_be_hash)
        end
      end
    end
  end
end
