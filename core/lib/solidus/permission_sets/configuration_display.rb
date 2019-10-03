# frozen_string_literal: true

module Solidus
  module PermissionSets
    class ConfigurationDisplay < PermissionSets::Base
      def activate!
          can [:edit, :admin], :general_settings
          can [:display, :admin], Solidus::TaxCategory
          can [:display, :admin], Solidus::TaxRate
          can [:display, :admin], Solidus::Zone
          can [:display, :admin], Solidus::Country
          can [:display, :admin], Solidus::State
          can [:display, :admin], Solidus::PaymentMethod
          can [:display, :admin], Solidus::Taxonomy
          can [:display, :admin], Solidus::ShippingMethod
          can [:display, :admin], Solidus::ShippingCategory
          can [:display, :admin], Solidus::StockLocation
          can [:display, :admin], Solidus::StockMovement
          can [:display, :admin], Solidus::RefundReason
          can [:display, :admin], Solidus::ReimbursementType
          can [:display, :admin], Solidus::ReturnReason
      end
    end
  end
end
