module Spree
  class PromotionRuleUser < Solidus::Base
    self.table_name = 'spree_promotion_rules_users'

    belongs_to :promotion_rule, class_name: 'Solidus::PromotionRule'
    belongs_to :user, class_name: Solidus::UserClassHandle.new
  end
end
