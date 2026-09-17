# frozen_string_literal: true

module SolidusPromotions
  module PermissionSets
    class SolidusPromotionManagement < Spree::PermissionSets::Base
      class << self
        def privilege
          :management
        end

        def category
          :solidus_promotion
        end
      end

      def activate!
        can :manage, SolidusPromotions::Promotion
        can :manage, SolidusPromotions::Condition
        can :manage, SolidusPromotions::Benefit
        can :manage, SolidusPromotions::PromotionCategory
        can :manage, SolidusPromotions::PromotionCode
      end
    end
  end
end
