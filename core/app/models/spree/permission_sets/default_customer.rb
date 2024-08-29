# frozen_string_literal: true

module Spree
  module PermissionSets
    # Permissions for e-commerce customers.
    #
    # This permission set is always added to the `:default` role, which in turn
    # is the default role for all users without any explicit roles.
    #
    # Permissions include reading and updating orders when the ability's user
    # has been assigned as the order's user, unless the order is already
    # completed. Same is true for guest checkout orders.
    #
    # It grants read-only permissions for the following resources typically used
    # during a checkout process:
    #
    # - Zones
    # - Countries
    # - States
    # - Taxons
    # - Taxonomies
    # - Products
    # - Properties
    # - Product properties
    # - Variants
    # - Option types
    # - Option values
    # - Stock items
    # - Stock locations
    #
    # Abilities with this role can also create refund authorizations for orders
    # with the same user, as well as reading and updating the user record and
    # their associated cards.
    class DefaultCustomer < PermissionSets::Base
      class << self
        def privilege
          :other
        end

        def category
          :default_customer
        end
      end

      def activate!
        can :read, Country
        can :read, OptionType
        can :read, OptionValue
        can :create, Order do |order, token|
          # same user, or both nil
          order.user == user ||
            # guest checkout order
            order.email.present? ||
            # via API, just like with show and update
            (order.guest_token.present? && token == order.guest_token)
        end
        can [:show, :update], Order, Order.where(user:) do |order, token|
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
        can :read, StockItem, stock_location: {active: true}
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
