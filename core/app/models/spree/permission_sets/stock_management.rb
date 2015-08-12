module Spree
  module PermissionSets
    class StockManagement < PermissionSets::Base
      def activate!
        can :manage, Spree::StockItem
      end
    end
  end
end
