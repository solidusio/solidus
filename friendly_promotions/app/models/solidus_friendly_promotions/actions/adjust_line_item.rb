# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Actions
    class AdjustLineItem < PromotionAction
      def can_discount?(object)
        object.is_a? Spree::LineItem
      end

      def available_calculators
        SolidusFriendlyPromotions.config.line_item_discount_calculators
      end
    end
  end
end
