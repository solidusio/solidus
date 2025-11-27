# frozen_string_literal: true

module SolidusPromotions
  module Benefits
    class AdjustLineItem < Benefit
      def discount_line_item(line_item, ...)
        amount = compute_amount(line_item, ...)
        return if amount.zero?

        ItemDiscount.new(
          item: line_item,
          label: adjustment_label(line_item),
          amount: amount,
          source: self
        )
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
