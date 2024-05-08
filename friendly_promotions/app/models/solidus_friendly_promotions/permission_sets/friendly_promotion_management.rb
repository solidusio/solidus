# frozen_string_literal: true

module SolidusFriendlyPromotions
  module PermissionSets
    class FriendlyPromotionManagement < Spree::PermissionSets::Base
      def activate!
        can :manage, SolidusFriendlyPromotions::Promotion
        can :manage, SolidusFriendlyPromotions::PromotionRule
        can :manage, SolidusFriendlyPromotions::Benefit
        can :manage, SolidusFriendlyPromotions::PromotionCategory
        can :manage, SolidusFriendlyPromotions::PromotionCode
      end
    end
  end
end
