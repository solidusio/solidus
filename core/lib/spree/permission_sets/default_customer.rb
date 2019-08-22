# frozen_string_literal: true

module Spree
  module PermissionSets
    class DefaultCustomer < PermissionSets::Base
      def activate!
        can :display, Country
        can :display, OptionType
        can :display, OptionValue
        can :create, Order
        can [:read, :update], Order, Order.where(user: user) do |order, token|
          order.user == user || (order.guest_token.present? && token == order.guest_token)
        end
        cannot :update, Order do |order|
          order.completed?
        end
        can :create, ReturnAuthorization do |return_authorization|
          return_authorization.order.user == user
        end
        can [:display, :update], CreditCard, user_id: user.id
        can :display, Product
        can :display, ProductProperty
        can :display, Property
        can :create, Spree.user_class
        can [:read, :update, :update_email], Spree.user_class, id: user.id
        can :display, State
        can :display, StockItem, stock_location: { active: true }
        can :display, StockLocation, active: true
        can :display, Taxon
        can :display, Taxonomy
        can [:save_in_address_book, :remove_from_address_book], Spree.user_class, id: user.id
        can [:display, :view_out_of_stock], Variant
        can :display, Zone
      end
    end
  end
end
