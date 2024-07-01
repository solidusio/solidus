# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    class Store < Condition
      include OrderLevelCondition

      has_many :condition_stores, class_name: "SolidusPromotions::ConditionStore",
        foreign_key: :condition_id,
        dependent: :destroy
      has_many :stores, through: :condition_stores, class_name: "Spree::Store"

      def preload_relations
        [:stores]
      end

      def eligible?(order, _options = {})
        stores.none? || stores.include?(order.store)
      end

      def updateable?
        true
      end
    end
  end
end
