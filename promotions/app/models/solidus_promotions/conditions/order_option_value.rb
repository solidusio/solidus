# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    class OrderOptionValue < Condition
      include OptionValueCondition

      def order_eligible?(order, _options = {})
        order.line_items.any? do |line_item|
          LineItemOptionValue.new(preferred_eligible_values: preferred_eligible_values).eligible?(line_item)
        end
      end

      def to_partial_path
        "solidus_promotions/admin/condition_fields/option_value"
      end
    end
  end
end
