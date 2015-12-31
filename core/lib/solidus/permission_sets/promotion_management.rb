module Spree
  module PermissionSets
    class PromotionManagement < PermissionSets::Base
      def activate!
        can :manage, Spree::Promotion
        can :manage, Spree::PromotionRule
        can :manage, Spree::PromotionAction
        can :manage, Spree::PromotionCategory
      end
    end
  end
end
