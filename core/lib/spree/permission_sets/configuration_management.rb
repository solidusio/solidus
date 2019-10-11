# frozen_string_literal: true

module Solidus
  module PermissionSets
    class ConfigurationManagement < PermissionSets::Base
      def activate!
        can :manage, :general_settings
        can :manage, Solidus::TaxCategory
        can :manage, Solidus::TaxRate
        can :manage, Solidus::Zone
        can :manage, Solidus::Country
        can :manage, Solidus::State
        can :manage, Solidus::PaymentMethod
        can :manage, Solidus::Taxonomy
        can :manage, Solidus::ShippingMethod
        can :manage, Solidus::ShippingCategory
        can :manage, Solidus::StockLocation
        can :manage, Solidus::StockMovement
        can :manage, Solidus::RefundReason
        can :manage, Solidus::ReimbursementType
        can :manage, Solidus::ReturnReason
      end
    end
  end
end
