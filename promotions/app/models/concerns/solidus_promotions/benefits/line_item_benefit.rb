# frozen_string_literal: true

module SolidusPromotions
  module Benefits
    module LineItemBenefit
      def can_discount?(object)
        object.is_a? Spree::LineItem
      end

      def level
        :line_item
      end
      deprecate :level, deprecator: Spree.deprecator
    end
  end
end
