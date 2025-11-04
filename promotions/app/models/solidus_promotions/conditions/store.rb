# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    class Store < Condition
      # TODO: Remove in Solidus 5
      include OrderLevelCondition

      has_many :condition_stores,
        class_name: "SolidusPromotions::ConditionStore",
        foreign_key: :condition_id,
        dependent: :destroy,
        inverse_of: :condition
      has_many :stores, through: :condition_stores, class_name: "Spree::Store"

      def preload_relations
        [:stores]
      end

      def order_eligible?(order, _options = {})
        stores.none? || stores.include?(order.store)
      end

      def updateable?
        true
      end
    end
  end
end
