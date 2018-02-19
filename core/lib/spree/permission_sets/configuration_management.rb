# frozen_string_literal: true

module Spree
  module PermissionSets
    class ConfigurationManagement < PermissionSets::Base
      def activate!
        can :manage, :general_settings
        can :manage, Spree::TaxCategory
        can :manage, Spree::TaxRate
        can :manage, Spree::Zone
        can :manage, Spree::Country
        can :manage, Spree::State
        can :manage, Spree::PaymentMethod
        can :manage, Spree::Taxonomy
        can :manage, Spree::ShippingMethod
        can :manage, Spree::ShippingCategory
        can :manage, Spree::StockLocation
        can :manage, Spree::StockMovement
        can :manage, Spree::RefundReason
        can :manage, Spree::ReimbursementType
        can :manage, Spree::ReturnReason
      end
    end
  end
end
