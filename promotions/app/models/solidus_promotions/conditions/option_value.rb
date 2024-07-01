# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    class OptionValue < Condition
      include LineItemApplicableOrderCondition

      preference :eligible_values, :hash

      def order_eligible?(order)
        order.line_items.any? { |item| line_item_eligible?(item) }
      end

      def line_item_eligible?(line_item)
        LineItemOptionValue.new(preferred_eligible_values: preferred_eligible_values).eligible?(line_item)
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
