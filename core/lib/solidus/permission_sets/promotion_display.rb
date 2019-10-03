# frozen_string_literal: true

module Solidus
  module PermissionSets
    class PromotionDisplay < PermissionSets::Base
      def activate!
        can [:display, :admin, :edit], Solidus::Promotion
        can [:display, :admin], Solidus::PromotionRule
        can [:display, :admin], Solidus::PromotionAction
        can [:display, :admin], Solidus::PromotionCategory
        can [:display, :admin], Solidus::PromotionCode
      end
    end
  end
end
