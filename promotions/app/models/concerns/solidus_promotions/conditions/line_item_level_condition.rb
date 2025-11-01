# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    module LineItemLevelCondition
      def applicable?(promotable)
        promotable.is_a?(Spree::LineItem)
      end

      def level
        :line_item
      end
      deprecate :level, deprecator: Spree.deprecator
    end
  end
end
