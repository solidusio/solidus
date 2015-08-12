module Spree
  module PermissionSets
    class StockManagement < PermissionSets::Base
      def activate!
        can :manage, Spree::StockItem
        can :display, Spree::StockLocation
      end
    end
  end
end
