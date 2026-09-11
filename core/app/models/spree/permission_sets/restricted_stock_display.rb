# frozen_string_literal: true

module Spree
  module PermissionSets
    # Admin permissions for stock, limited to allowed locations.
    #
    # DefaultCustomer already grants every user plain `:read` on any active
    # stock location and its stock items, so this permission set's only
    # meaningful, genuinely-restricted grant is `:admin` (used to gate the
    # admin stock UI), not `:read`.
    class RestrictedStockDisplay < PermissionSets::Base
      class << self
        def privilege
          :display
        end

        def category
          :restricted_stock
        end
      end

      def activate!
        can [:read, :admin], Spree::StockItem, stock_location_id: location_ids
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
