# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Rules
    class User < PromotionRule
      include OrderLevelRule

      has_many :promotion_rules_users,
        class_name: "SolidusFriendlyPromotions::PromotionRulesUser",
        foreign_key: :promotion_rule_id,
        dependent: :destroy
      has_many :users, through: :promotion_rules_users, class_name: Spree::UserClassHandle.new

      def preload_relations
        [:users]
      end

      def eligible?(order, _options = {})
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
