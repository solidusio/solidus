# frozen_string_literal: true

module SolidusPromotions
  module Benefits
    class AdjustLineItem < Benefit
      def can_discount?(object)
        object.is_a? Spree::LineItem
      end

      def level
        :line_item
      end

      def possible_conditions
        super + SolidusPromotions.config.line_item_conditions
      end
    end
  end
end
