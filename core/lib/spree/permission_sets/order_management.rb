# frozen_string_literal: true

module Spree
  module PermissionSets
    # Full permissions for order management.
    #
    # This permission set grants full control over all order and related resources,
    # including:
    #
    # - Orders
    # - Payments
    # - Shipments
    # - Adjustments
    # - Line items
    # - Return authorizations
    # - Customer returns
    # - Order cancellations
    # - Reimbursements
    # - Return items
    # - Refunds
    #
    # It also allows reading reimbursement types, but not modifying them.
    class OrderManagement < PermissionSets::Base
      def activate!
        can :read, Spree::ReimbursementType
        can :manage, Spree::Order
        can :manage, Spree::Payment
        can :manage, Spree::Shipment
        can :manage, Spree::Adjustment
        can :manage, Spree::LineItem
        can :manage, Spree::ReturnAuthorization
        can :manage, Spree::CustomerReturn
        can :manage, Spree::OrderCancellations
        can :manage, Spree::Reimbursement
        can :manage, Spree::ReturnItem
        can :manage, Spree::Refund
      end
    end
  end
end
