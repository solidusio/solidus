# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Actions
    class AdjustLineItem < PromotionAction
      def can_discount?(object)
        object.is_a? Spree::LineItem
      end

      def level
        :line_item
      end

      def possible_conditions
        super + SolidusFriendlyPromotions.config.line_item_rules
      end
    end
  end
end
