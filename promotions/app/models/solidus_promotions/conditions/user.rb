# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    class User < Condition
      # TODO: Remove in Solidus 5
      include OrderLevelCondition

      has_many :condition_users,
        class_name: "SolidusPromotions::ConditionUser",
        foreign_key: :condition_id,
        dependent: :destroy,
        inverse_of: :condition
      has_many :users, through: :condition_users, class_name: Spree::UserClassHandle.new

      def preload_relations
        [:users]
      end

      def order_eligible?(order, _options = {})
        users.include?(order.user)
      end

      def user_ids_string
        user_ids.join(",")
      end

      def user_ids_string=(user_ids)
        self.user_ids = user_ids.to_s.split(",").map(&:strip)
      end

      def updateable?
        true
      end
    end
  end
end
