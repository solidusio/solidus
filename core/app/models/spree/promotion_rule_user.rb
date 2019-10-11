# frozen_string_literal: true

module Solidus
  class PromotionRuleUser < Solidus::Base
    self.table_name = 'spree_promotion_rules_users'

    belongs_to :promotion_rule, class_name: 'Solidus::PromotionRule', optional: true
    belongs_to :user, class_name: Solidus::UserClassHandle.new, optional: true
  end
end
