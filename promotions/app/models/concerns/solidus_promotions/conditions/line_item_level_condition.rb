# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    module LineItemLevelCondition
      def self.included(base)
        def base.method_added(method)
          if method == :eligible?
            Spree.deprecator.warn <<~MSG
              Defining `eligible?` on a promotion along with including the `LineItemLevelCondition` module is deprecated.
              Rename `eligible?` to `line_item_eligible?` and stop including the `LineItemLevelCondition` module.
            MSG
            define_method(:applicable?) do |promotable|
              promotable.is_a?(Spree::LineItem)
            end
          end

          super
        end
      end

      def level
        :line_item
      end
      deprecate :level, deprecator: Spree.deprecator
    end
  end
end
