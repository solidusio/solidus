# frozen_string_literal: true

module Solidus
  module PermissionSets
    class OrderManagement < PermissionSets::Base
      def activate!
        can :display, Solidus::ReimbursementType
        can :manage, Solidus::Order
        can :manage, Solidus::Payment
        can :manage, Solidus::Shipment
        can :manage, Solidus::Adjustment
        can :manage, Solidus::LineItem
        can :manage, Solidus::ReturnAuthorization
        can :manage, Solidus::CustomerReturn
        can :manage, Solidus::OrderCancellations
        can :manage, Solidus::Reimbursement
        can :manage, Solidus::ReturnItem
        can :manage, Solidus::Refund
      end
    end
  end
end
