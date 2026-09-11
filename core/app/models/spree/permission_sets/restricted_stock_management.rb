# frozen_string_literal: true

module Spree
  module PermissionSets
    # Full permissions for stock management limited to allowed locations.
    #
    # This permission set grants full control over all stock items a user has
    # access to their locations.
    class RestrictedStockManagement < PermissionSets::Base
      class << self
        def privilege
          :management
        end

        def category
          :restricted_stock
        end
      end

      def activate!
        can :manage, Spree::StockItem, stock_location_id: location_ids
        # No `can :read, Spree::StockLocation` here: every user, regardless of role,
        # already gets `can :read, StockLocation, active: true` from the always-on
        # `:default` role's DefaultCustomer permission set. CanCan combines rules for
        # the same subject with OR, so a narrower grant here can't restrict that wider
        # one — it can only ever widen it (to inactive locations) or do nothing.
      end

      private

      def location_ids
        @ids ||= user.stock_locations.pluck(:id)
      end
    end
  end
end
