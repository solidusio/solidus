# frozen_string_literal: true

module Spree
  module PermissionSets
    # Read permissions for stock limited to allowed locations.
    #
    # This permission set allows users to view information about stock items and
    # locations, both of them limited to locations they have access to.
    # Permissions are also granted for the admin panel for items.
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
        can :read, Spree::StockLocation, id: location_ids
      end

      private

      def location_ids
        @ids ||= user.stock_locations.pluck(:id)
      end
    end
  end
end
