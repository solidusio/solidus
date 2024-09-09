# frozen_string_literal: true

module Spree
  module PermissionSets
    # Read-only permissions for e-commerce settings.
    #
    # Roles with this permission will be able to view information, also from the admin
    # panel, about:
    #
    # - Tax categories
    # - Tax rates
    # - Zones
    # - Countries
    # - States
    # - Payment methods
    # - Taxonomies
    # - Shipping methods
    # - Shipping categories
    # - Stock locations
    # - Stock movements
    # - Refund reasons
    # - Reimbursement types
    # - Return reasons
    class ConfigurationDisplay < PermissionSets::Base
      class << self
        def privilege
          :display
        end

        def category
          :configuration
        end
      end

      def activate!
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
