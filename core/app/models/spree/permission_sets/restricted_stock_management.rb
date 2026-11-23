# frozen_string_literal: true

module Spree
  module PermissionSets
    # Full permissions for stock management limited to allowed locations.
    #
    # This permission set grants full control over all stock items in the
    # locations a user has access to. Those locations are also readable by the
    # corresponding ability.
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
        can :read, Spree::StockLocation, id: location_ids
      end

      private

      def location_ids
        @ids ||= user.stock_locations.pluck(:id)
      end
    end
  end
end
