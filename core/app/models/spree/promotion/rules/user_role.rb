module Spree
  class Promotion
    module Rules
      class UserRole < PromotionRule
        has_many :promotion_rule_roles,
          class_name: 'Spree::PromotionRuleRole',
          foreign_key: :promotion_rule_id,
          dependent: :destroy

        has_many :roles,
          through: :promotion_rule_roles,
          class_name: 'Spree::Role'

        accepts_nested_attributes_for :roles

        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        def eligible?(order, options = {})
          (roles & order.user.spree_roles).any? if order.user
        end
      end
    end
  end
end
