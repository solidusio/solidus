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
    end
  end
end
