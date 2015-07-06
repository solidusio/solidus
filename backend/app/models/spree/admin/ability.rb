module Spree
  module Admin
    class Ability
      include CanCan::Ability

      def initialize user
        # TODO: this could be extracted out to a sub role eventually
        if user.has_spree_role?(:dashboard_display)
          can [:admin, :home], :dashboards
        end

        if user.has_spree_role? :promotion_management
          can :manage, Spree::Promotion
          can :manage, Spree::PromotionRule
          can :manage, Spree::PromotionAction
          can :manage, Spree::PromotionCategory
        end

        if user.has_spree_role? :promotion_display
          can [:display, :admin], Spree::Promotion
          can [:display, :admin], Spree::PromotionRule
          can [:display, :admin], Spree::PromotionAction
          can [:display, :admin], Spree::PromotionCategory
        end

        if user.has_spree_role? :order_management
          can :manage, Spree::Order
          can :manage, Spree::Payment
          can :manage, Spree::Shipment
          can :manage, Spree::Adjustment
          can :manage, Spree::LineItem
          can :manage, Spree::ReturnAuthorization
          can :manage, Spree::CustomerReturn
        end

        if user.has_spree_role? :order_display
          can [:display, :admin, :edit, :cart], Spree::Order
          can [:display, :admin], Spree::Payment
          can [:display, :admin], Spree::Shipment
          can [:display, :admin], Spree::Adjustment
          can [:display, :admin], Spree::LineItem
          can [:display, :admin], Spree::ReturnAuthorization
          can [:display, :admin], Spree::CustomerReturn
        end

        if user.has_spree_role? :report_display
          can [:display, :admin, :sales_total], :reports
        end

        if user.has_spree_role? :stock_management
          can :manage, Spree::StockItem
          can :manage, Spree::StockTransfer
          can :manage, Spree::TransferItem
        end

        if user.has_spree_role? :stock_display
          can [:display, :admin], Spree::StockItem
          can [:display, :admin], Spree::StockTransfer
        end

        if user.has_spree_role? :product_management
          can :manage, Spree::Product
          can :manage, Spree::Image
          can :manage, Spree::Variant
          can :manage, Spree::OptionValue
          can :manage, Spree::ProductProperty
          can :manage, Spree::OptionType
          can :manage, Spree::Property
          can :manage, Spree::Prototype
          can :manage, Spree::Taxonomy
          can :manage, Spree::Taxon
          can :manage, Spree::Classification
        end

        if user.has_spree_role? :product_display
          can [:display, :admin, :edit], Spree::Product
          can [:display, :admin], Spree::Image
          can [:display, :admin], Spree::Variant
          can [:display, :admin], Spree::OptionValue
          can [:display, :admin], Spree::ProductProperty
          can [:display, :admin], Spree::OptionType
          can [:display, :admin], Spree::Property
          can [:display, :admin], Spree::Prototype
          can [:display, :admin], Spree::Taxonomy
          can [:display, :admin], Spree::Taxon
        end

        if user.has_spree_role? :user_management
          can :manage, Spree.user_class
          can :manage, Spree::StoreCredit
          can :display, Spree::Role
        end

        if user.has_spree_role? :user_display
          can [:display, :admin, :edit, :addresses, :orders, :items], Spree.user_class
          can [:display, :admin], Spree::StoreCredit
          can :display, Spree::Role
        end

        if user.has_spree_role? :configuration_management
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
          can :manage, Spree::Tracker
          can :manage, Spree::RefundReason
          can :manage, Spree::ReimbursementType
          can :manage, Spree::ReturnReason
        end

        if user.has_spree_role? :configuration_display
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
          can [:display, :admin], Spree::Tracker
          can [:display, :admin], Spree::RefundReason
          can [:display, :admin], Spree::ReimbursementType
          can [:display, :admin], Spree::ReturnReason
        end
      end
    end
  end
end
