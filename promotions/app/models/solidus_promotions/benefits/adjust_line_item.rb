# frozen_string_literal: true

module SolidusPromotions
  module Benefits
    class AdjustLineItem < Benefit
      def discount_line_item(line_item, ...)
        adjustment = find_adjustment(line_item) || build_adjustment(line_item)
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

      private

      def find_adjustment(line_item)
        line_item.adjustments.detect do |adjustment|
          adjustment.source == self
        end
      end

      def build_adjustment(line_item)
        line_item.adjustments.build(
          order: line_item.order,
          source: self
        )
      end
    end
  end
end
