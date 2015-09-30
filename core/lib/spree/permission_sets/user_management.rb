module Spree
  module PermissionSets
    class UserManagement < PermissionSets::Base
      def activate!
        can :manage, Spree.user_class
        cannot [:delete, :destroy], Spree.user_class
        can :manage, Spree::StoreCredit
        can :display, Spree::Role
      end
    end
  end
end
