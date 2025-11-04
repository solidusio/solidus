# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    module LineItemApplicableOrderLevelCondition
      def self.included(klass)
        klass.preference :line_item_applicable, :boolean, default: true
      end

      def applicable?(promotable)
        promotable.is_a?(Spree::LineItem) ? preferred_line_item_applicable && super : super
      end

      def level
        :order
      end
      deprecate :level, deprecator: Spree.deprecator
    end
  end
end
