# frozen_string_literal: true

module Solidus
  module PermissionSets
    class OrderDisplay < PermissionSets::Base
      def activate!
        can [:display, :admin, :edit, :cart], Solidus::Order
        can [:display, :admin], Solidus::Payment
        can [:display, :admin], Solidus::Shipment
        can [:display, :admin], Solidus::Adjustment
        can [:display, :admin], Solidus::LineItem
        can [:display, :admin], Solidus::ReturnAuthorization
        can [:display, :admin], Solidus::CustomerReturn
        can [:display, :admin], Solidus::OrderCancellations
        can [:display, :admin], Solidus::Reimbursement
        can [:display, :admin], Solidus::ReturnItem
        can [:display, :admin], Solidus::Refund
      end
    end
  end
end
