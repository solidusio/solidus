# frozen_string_literal: true

module Spree
  module PermissionSets
    class OrderDisplay < PermissionSets::Base
      def activate!
        can [:display, :admin, :edit, :cart], Spree::Order
        can [:display, :admin], Spree::Payment
        can [:display, :admin], Spree::Shipment
        can [:display, :admin], Spree::Adjustment
        can [:display, :admin], Spree::LineItem
        can [:display, :admin], Spree::ReturnAuthorization
        can [:display, :admin], Spree::CustomerReturn
        can [:display, :admin], Spree::OrderCancellations
        can [:display, :admin], Spree::Reimbursement
        can [:display, :admin], Spree::ReturnItem
        can [:display, :admin], Spree::Refund
      end
    end
  end
end
