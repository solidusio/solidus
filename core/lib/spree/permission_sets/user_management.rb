# frozen_string_literal: true

module Solidus
  module PermissionSets
    class UserManagement < PermissionSets::Base
      def activate!
        can [:admin, :display, :create, :update, :save_in_address_book, :remove_from_address_book, :addresses, :orders, :items], Solidus.user_class

        # Note: This does not work with accessible_by.
        # See https://github.com/solidusio/solidus/pull/1263
        can :update_email, Solidus.user_class do |user|
          user.spree_roles.none?
        end

        cannot [:delete, :destroy], Solidus.user_class
        can :manage, Solidus::StoreCredit
        can :display, Solidus::Role
      end
    end
  end
end
