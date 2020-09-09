# frozen_string_literal: true

module Spree
  module PermissionSets
    class DefaultCustomer < PermissionSets::Base
      def activate!
        can :read, Country
        can :read, OptionType
        can :read, OptionValue
        can :create, Order
        can [:show, :update], Order, Order.where(user: user) do |order, token|
          order.user == user || (order.guest_token.present? && token == order.guest_token)
        end
        cannot :update, Order do |order|
          order.completed?
        end
        can :create, ReturnAuthorization do |return_authorization|
          return_authorization.order.user == user
        end
        can [:read, :update], CreditCard, user_id: user.id
        can :read, Product
        can :read, ProductProperty
        can :read, Property
        can :create, Spree.user_class
        can [:show, :update, :update_email], Spree.user_class, id: user.id
        can :read, State
        can :read, StockItem, stock_location: { active: true }
        can :read, StockLocation, active: true
        can :read, Taxon
        can :read, Taxonomy
        can [:save_in_address_book, :remove_from_address_book], Spree.user_class, id: user.id
        can [:read, :view_out_of_stock], Variant
        can :read, Zone
      end
    end
  end
end
