module Spree
  module Admin
    class Ability
      include CanCan::Ability

      def initialize user
        if user.has_spree_role? :promotion_management
          can :manage, Spree::Promotion
          can :manage, Spree::PromotionRule
          can :manage, Spree::PromotionAction
          can :manage, Spree::PromotionCategory
        end

        if user.has_spree_role? :promotion_display
          can [:display, :admin], Spree::Promotion
          can [:display, :admin], Spree::PromotionRule
          can [:display, :admin], Spree::PromotionAction
          can [:display, :admin], Spree::PromotionCategory
        end

        if user.has_spree_role? :order_management
          can :manage, Spree::Order
          can :manage, Spree::Payment
          can :manage, Spree::Shipment
          can :manage, Spree::Adjustment
          can :manage, Spree::LineItem
          can :manage, Spree::ReturnAuthorization
          can :manage, Spree::CustomerReturn
        end

        if user.has_spree_role? :order_display
          can [:display, :admin, :edit, :cart], Spree::Order
          can [:display, :admin], Spree::Payment
          can [:display, :admin], Spree::Shipment
          can [:display, :admin], Spree::Adjustment
          can [:display, :admin], Spree::LineItem
          can [:display, :admin], Spree::ReturnAuthorization
          can [:display, :admin], Spree::CustomerReturn
        end
      end
    end
  end
end
