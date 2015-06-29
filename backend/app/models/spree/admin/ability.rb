module Spree
  module Admin
    class Ability
      include CanCan::Ability

      def initialize user
        if user.has_spree_role? :promotion_management
          can :manage, Spree::Promotion
          can :manage, Spree::PromotionRule
          can :manage, Spree::PromotionAction
          can :manage, Spree::PromotionCategory
        end

        if user.has_spree_role? :promotion_display
          can [:display, :admin], Spree::Promotion
          can [:display, :admin], Spree::PromotionRule
          can [:display, :admin], Spree::PromotionAction
          can [:display, :admin], Spree::PromotionCategory
        end
      end
    end
  end
end
