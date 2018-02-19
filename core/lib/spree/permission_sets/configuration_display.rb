# frozen_string_literal: true

module Spree
  module PermissionSets
    class ConfigurationDisplay < PermissionSets::Base
      def activate!
          can [:edit, :admin], :general_settings
          can [:display, :admin], Spree::TaxCategory
          can [:display, :admin], Spree::TaxRate
          can [:display, :admin], Spree::Zone
          can [:display, :admin], Spree::Country
          can [:display, :admin], Spree::State
          can [:display, :admin], Spree::PaymentMethod
          can [:display, :admin], Spree::Taxonomy
          can [:display, :admin], Spree::ShippingMethod
          can [:display, :admin], Spree::ShippingCategory
          can [:display, :admin], Spree::StockLocation
          can [:display, :admin], Spree::StockMovement
          can [:display, :admin], Spree::RefundReason
          can [:display, :admin], Spree::ReimbursementType
          can [:display, :admin], Spree::ReturnReason
      end
    end
  end
end
