# frozen_string_literal: true

module Spree
  module PermissionSets
    class OrderDisplay < PermissionSets::Base
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
