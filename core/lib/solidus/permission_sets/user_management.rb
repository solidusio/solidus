module Solidus
  module PermissionSets
    class UserManagement < PermissionSets::Base
      def activate!
        can [:admin, :display, :create, :update, :save_in_address_book, :remove_from_address_book, :addresses, :orders, :items], Solidus.user_class

        # due to how cancancan filters by associations,
        # we have to define this twice, once for `accessible_by`
        can :update_email, Solidus.user_class, solidus_roles: { id: nil }
        # and once for `can?`
        can :update_email, Solidus.user_class do |user|
          user.solidus_roles.none?
        end

        cannot [:delete, :destroy], Solidus.user_class
        can :manage, Solidus::StoreCredit
        can :display, Solidus::Role
      end
    end
  end
end
