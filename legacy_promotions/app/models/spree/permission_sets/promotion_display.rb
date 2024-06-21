# frozen_string_literal: true

module Spree
  module PermissionSets
    # Read-only permissions for promotions.
    #
    # This permission set allows users to view all related information about
    # promotions, also from the admin panel, including:
    #
    # - Promotions
    # - Promotion rules
    # - Promotion actions
    # - Promotion categories
    # - Promotion codes
    class PromotionDisplay < PermissionSets::Base
      def activate!
        can [:read, :admin, :edit], Spree::Promotion
        can [:read, :admin], Spree::PromotionRule
        can [:read, :admin], Spree::PromotionAction
        can [:read, :admin], Spree::PromotionCategory
        can [:read, :admin], Spree::PromotionCode
      end
    end
  end
end
