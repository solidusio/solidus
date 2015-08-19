module Spree
  module PermissionSets
    class OrderManagement < PermissionSets::Base
      def activate!
        can :display, Spree::ReimbursementType
        can :manage, Spree::Order
        can :manage, Spree::Payment
        can :manage, Spree::Shipment
        can :manage, Spree::Adjustment
        can :manage, Spree::LineItem
        can :manage, Spree::ReturnAuthorization
        can :manage, Spree::CustomerReturn
        can :manage, Spree::OrderCancellations
      end
    end
  end
end
