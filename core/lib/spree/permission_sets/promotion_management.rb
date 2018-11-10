# frozen_string_literal: true

module Spree
  module PermissionSets
    class PromotionManagement < PermissionSets::Base
      def activate!
        can :manage, Spree::Promotion
        can :manage, Spree::PromotionRule
        can :manage, Spree::PromotionAction
        can :manage, Spree::PromotionCategory
        can :manage, Spree::PromotionCode
      end
    end
  end
end
