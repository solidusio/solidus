# frozen_string_literal: true

module Spree
  module PermissionSets
    # Read permissions for orders.
    #
    # This permission set allows users to view all related information about
    # orders, also from the admin panel, including:
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
    # However, it does not allow any modifications to be made to any of these
    # resources.
    class OrderDisplay < PermissionSets::Base
      class << self
        def privilege
          :display
        end

        def category
          :order
        end
      end

      def activate!
        can [:read, :admin, :edit, :cart], Spree::Order
        can [:read, :admin], Spree::Payment
        can [:read, :admin], Spree::Shipment
        can [:read, :admin], Spree::Adjustment
        can [:read, :admin], Spree::LineItem
        can [:read, :admin], Spree::ReturnAuthorization
        can [:read, :admin], Spree::CustomerReturn
        can [:read, :admin], Spree::OrderCancellations
        can [:read, :admin], Spree::Reimbursement
        can [:read, :admin], Spree::ReturnItem
        can [:read, :admin], Spree::Refund
      end
    end
  end
end
