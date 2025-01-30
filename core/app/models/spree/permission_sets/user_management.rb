# frozen_string_literal: true

module Spree
  module PermissionSets
    # Full permissions for user management.
    #
    # This permission set grants full control over all user and
    # related resources, including:
    #
    # - Users
    # - Store credits
    # - Roles
    # - API keys
    class UserManagement < PermissionSets::Base
      class << self
        def privilege
          :management
        end

        def category
          :user
        end
      end

      def activate!
        can [:admin, :read, :create, :update, :save_in_address_book, :remove_from_address_book, :addresses, :orders, :items], Spree.user_class

        # NOTE: This does not work with accessible_by.
        # See https://github.com/solidusio/solidus/pull/1263
        can :update_email, Spree.user_class do |user|
          user.spree_roles.none?
        end
        can :update_password, Spree.user_class do |user|
          user.spree_roles.none?
        end

        cannot :destroy, Spree.user_class
        can :manage, Spree::StoreCredit
        can :manage, :api_key
        can :read, Spree::Role
      end
    end
  end
end
