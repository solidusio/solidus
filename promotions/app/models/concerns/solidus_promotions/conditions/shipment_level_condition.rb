# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    module ShipmentLevelCondition
      def self.included(base)
        def base.method_added(method)
          if method == :eligible?
            Spree.deprecator.warn <<~MSG
              Defining `eligible?` on a promotion along with including the `ShipmentLevelCondition` module is deprecated.
              Rename `eligible?` to `shipment_eligible?` and stop including the `ShipmentLevelCondition` module.
            MSG
            define_method(:applicable?) do |promotable|
              promotable.is_a?(Spree::Shipment)
            end
          end

          super
        end
      end

      def level
        :shipment
      end
    end
  end
end
