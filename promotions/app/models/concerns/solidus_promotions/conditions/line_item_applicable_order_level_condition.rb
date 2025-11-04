# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    module LineItemApplicableOrderLevelCondition
      def self.included(klass)
        klass.preference :line_item_applicable, :boolean, default: true
      end

      def applicable?(promotable)
        if preferred_line_item_applicable == false
          Spree.deprecator.warn <<~MSG
            Setting `#{self.class.name}#preferred_line_item_applicable` to false is deprecated.
            Please use a suitable condition that only checks the order instead, such as `OrderProduct`,
            `OrderTaxon`, or `OrderOptionValue`. If you have included the `LineItemApplicableOrderLevelCondition` module
            yourself, create a new condition that only checks orders:
            ```
            class MyCondition < SolidusPromotions::Condition
              def order_eligible?(order, _options = {})
                # your logic here
              end
            end
            ```
          MSG
        end
        promotable.is_a?(Spree::LineItem) ? preferred_line_item_applicable && super : super
      end

      def level
        :order
      end
      deprecate :level, deprecator: Spree.deprecator
    end
  end
end
