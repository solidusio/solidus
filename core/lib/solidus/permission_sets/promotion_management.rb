module Solidus
  module PermissionSets
    class PromotionManagement < PermissionSets::Base
      def activate!
        can :manage, Solidus::Promotion
        can :manage, Solidus::PromotionRule
        can :manage, Solidus::PromotionAction
        can :manage, Solidus::PromotionCategory
      end
    end
  end
end
