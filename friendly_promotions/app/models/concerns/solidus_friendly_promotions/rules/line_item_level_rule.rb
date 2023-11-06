# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Rules
    module LineItemLevelRule
      def applicable?(promotable)
        promotable.is_a?(Spree::LineItem)
      end

      def level
        :line_item
      end
    end
  end
end
