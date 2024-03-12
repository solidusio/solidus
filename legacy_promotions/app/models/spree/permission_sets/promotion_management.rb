# frozen_string_literal: true

module Spree
  module PermissionSets
    # Full permissions for promotion management.
    #
    # This permission set grants full control over all promotion and related resources,
    # including:
    #
    # - Promotions
    # - Promotion rules
    # - Promotion actions
    # - Promotion categories
    # - Promotion codes
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
