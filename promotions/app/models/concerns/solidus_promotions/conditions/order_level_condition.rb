# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    module OrderLevelCondition
      def self.included(base)
        def base.method_added(method)
          if method == :eligible?
            Spree.deprecator.warn <<~MSG
              Defining `eligible?` on a promotion along with including the `OrderLevelCondition` module is deprecated.
              Rename `eligible?` to `order_eligible?` and stop including the `OrderLevelCondition` module.
            MSG
            define_method(:applicable?) do |promotable|
              promotable.is_a?(Spree::Order)
            end
          end

          super
        end
      end

      def level
        :order
      end
    end
  end
end
