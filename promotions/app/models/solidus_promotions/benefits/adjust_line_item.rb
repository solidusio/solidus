# frozen_string_literal: true

module SolidusPromotions
  module Benefits
    class AdjustLineItem < Benefit
      def discount_line_item(line_item, ...)
        adjustment = line_item.adjustments.detect do |adjustment|
          adjustment.source == self
        end || line_item.adjustments.build(
          order: line_item.order,
          source: self
        )
        adjustment.amount = compute_amount(line_item, ...)
        adjustment.label = adjustment_label(line_item)
        adjustment
      end

      def possible_conditions
        super + SolidusPromotions.config.line_item_conditions
      end

      def level
        :line_item
      end
      deprecate :level, deprecator: Spree.deprecator
    end
  end
end
