# frozen_string_literal: true

module Spree
  module PermissionSets
    class PromotionDisplay < PermissionSets::Base
      def activate!
        can [:display, :admin, :edit], Spree::Promotion
        can [:display, :admin], Spree::PromotionRule
        can [:display, :admin], Spree::PromotionAction
        can [:display, :admin], Spree::PromotionCategory
        can [:display, :admin], Spree::PromotionCode
      end
    end
  end
end
