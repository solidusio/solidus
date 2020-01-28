# frozen_string_literal: true

module Spree
  module PermissionSets
    class UserManagement < PermissionSets::Base
      def activate!
        can [:admin, :display, :create, :update, :save_in_address_book, :remove_from_address_book, :addresses, :orders, :items], Spree.user_class

        # Note: This does not work with accessible_by.
        # See https://github.com/solidusio/solidus/pull/1263
        can :update_email, Spree.user_class do |user|
          user.spree_roles.none?
        end
        can :update_password, Spree.user_class do |user|
          user.spree_roles.none?
        end

        cannot [:delete, :destroy], Spree.user_class
        can :manage, Spree::StoreCredit
        can :display, Spree::Role
        can :manage, :api_key
      end
    end
  end
end
