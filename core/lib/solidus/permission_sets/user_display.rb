# frozen_string_literal: true

module Solidus
  module PermissionSets
    class UserDisplay < PermissionSets::Base
      def activate!
        can [:display, :admin, :edit, :addresses, :orders, :items], Solidus.user_class
        can [:display, :admin], Solidus::StoreCredit
        can :display, Solidus::Role
      end
    end
  end
end
