# frozen_string_literal: true

module Spree
  module PermissionSets
    # Full permissions for stock management.
    #
    # This permission set grants full control over all stock items and read
    # access to locations.
    class StockManagement < PermissionSets::Base
      class << self
        def privilege
          :management
        end

        def category
          :stock
        end
      end

      def activate!
        can :manage, Spree::StockItem
        can :read, Spree::StockLocation
      end
    end
  end
end
