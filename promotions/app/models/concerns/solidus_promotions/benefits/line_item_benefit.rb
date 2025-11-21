# frozen_string_literal: true

module SolidusPromotions
  module Benefits
    module LineItemBenefit
      def self.included(_base)
        Spree.deprecator.warn("Including #{name} is deprecated.")
      end

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
