# frozen_string_literal: true

module Spree
  module PermissionSets
    class ConfigurationDisplay < PermissionSets::Base
      def activate!
          can [:edit, :admin], :general_settings
          can [:read, :admin], Spree::TaxCategory
          can [:read, :admin], Spree::TaxRate
          can [:read, :admin], Spree::Zone
          can [:read, :admin], Spree::Country
          can [:read, :admin], Spree::State
          can [:read, :admin], Spree::PaymentMethod
          can [:read, :admin], Spree::Taxonomy
          can [:read, :admin], Spree::ShippingMethod
          can [:read, :admin], Spree::ShippingCategory
          can [:read, :admin], Spree::StockLocation
          can [:read, :admin], Spree::StockMovement
          can [:read, :admin], Spree::RefundReason
          can [:read, :admin], Spree::ReimbursementType
          can [:read, :admin], Spree::ReturnReason
      end
    end
  end
end
