module Spree
  module PermissionSets
    class UserManagement < PermissionSets::Base
      def activate!
        # due to how cancancan filters by associations,
        # we have to define this twice, once for `accessible_by`
        can :manage, Spree.user_class, spree_roles: { id: nil }
        # and once for `can?`
        can :manage, Spree.user_class do |user|
          user.spree_roles.none?
        end

        can :manage, Spree.user_class, id: user.id if user
        cannot [:delete, :destroy], Spree.user_class
        can :manage, Spree::StoreCredit
        can :display, Spree::Role
      end
    end
  end
end
