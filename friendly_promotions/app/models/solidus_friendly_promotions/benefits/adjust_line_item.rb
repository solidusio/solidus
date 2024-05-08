# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Benefits
    class AdjustLineItem < Benefit
      def can_discount?(object)
        object.is_a? Spree::LineItem
      end

      def level
        :line_item
      end

      def possible_conditions
        super + SolidusFriendlyPromotions.config.line_item_conditions
      end
    end
  end
end
