# frozen_string_literal: true

module SolidusPromotions
  module PermissionSets
    class FriendlyPromotionManagement < Spree::PermissionSets::Base
      def activate!
        can :manage, SolidusPromotions::Promotion
        can :manage, SolidusPromotions::PromotionRule
        can :manage, SolidusPromotions::Benefit
        can :manage, SolidusPromotions::PromotionCategory
        can :manage, SolidusPromotions::PromotionCode
      end
    end
  end
end
