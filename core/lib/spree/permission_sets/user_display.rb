# frozen_string_literal: true

module Spree
  module PermissionSets
    class UserDisplay < PermissionSets::Base
      def activate!
        can [:read, :admin, :edit, :addresses, :orders, :items], Spree.user_class
        can [:read, :admin], Spree::StoreCredit
        can :read, Spree::Role
      end
    end
  end
end
