# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Rules
    class OptionValue < ::Spree::PromotionRule
      preference :eligible_values, :hash

      def applicable?(promotable)
        promotable.is_a?(Spree::Order)
      end

      def eligible?(order, _options = {})
        order.line_items.any? do |item|
          LineItemOptionValue.new(preferred_eligible_values: preferred_eligible_values).eligible?(item)
        end
      end

      def preferred_eligible_values
        values = preferences[:eligible_values] || {}
        values.keys.map(&:to_i).zip(
          values.values.map do |value|
            (value.is_a?(Array) ? value : value.split(",")).map(&:to_i)
          end
        ).to_h
      end
    end
  end
end
