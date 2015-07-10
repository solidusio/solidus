module Spree
  module PermissionSets
    class PromotionDisplay < PermissionSets::Base
      def activate!
        can [:display, :admin], Spree::Promotion
        can [:display, :admin], Spree::PromotionRule
        can [:display, :admin], Spree::PromotionAction
        can [:display, :admin], Spree::PromotionCategory
      end
    end
  end
end
