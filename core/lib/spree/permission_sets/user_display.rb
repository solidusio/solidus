# frozen_string_literal: true

module Spree
  module PermissionSets
    class UserDisplay < PermissionSets::Base
      def activate!
        can [:display, :admin, :edit, :addresses, :orders, :items], Spree.user_class
        can [:display, :admin], Spree::StoreCredit
        can :display, Spree::Role
      end
    end
  end
end
