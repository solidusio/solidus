# frozen_string_literal: true

module Spree
  module PermissionSets
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
