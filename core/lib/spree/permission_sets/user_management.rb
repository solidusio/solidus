module Spree
  module PermissionSets
    class UserManagement < PermissionSets::Base
      def activate!
        can [:admin, :display, :create, :update, :save_in_address_book, :remove_from_address_book, :addresses, :orders, :items], Spree.user_class

        # due to how cancancan filters by associations,
        # we have to define this twice, once for `accessible_by`
        can :update_email, Spree.user_class, spree_roles: { id: nil }
        # and once for `can?`
        can :update_email, Spree.user_class do |user|
          user.spree_roles.none?
        end

        cannot [:delete, :destroy], Spree.user_class
        can :manage, Spree::StoreCredit
        can :display, Spree::Role
      end
    end
  end
end
