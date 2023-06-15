# frozen_string_literal: true

module Spree
  module PermissionSets
    # Read-only permissions for stock.
    #
    # This permission set allows users to view information about stock items
    # (also from the admin panel) and stock locations.
    class StockDisplay < PermissionSets::Base
      def activate!
        can [:read, :admin], Spree::StockItem
        can :read, Spree::StockLocation
      end
    end
  end
end
