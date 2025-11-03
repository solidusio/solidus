# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    class OptionValue < Condition
      include LineItemApplicableOrderLevelCondition

      include OptionValueCondition

      def order_eligible?(order, _options = {})
        order.line_items.any? { |item| line_item_eligible?(item) }
      end

      def line_item_eligible?(line_item, _options = {})
        LineItemOptionValue.new(preferred_eligible_values: preferred_eligible_values).eligible?(line_item)
      end
    end
  end
end
