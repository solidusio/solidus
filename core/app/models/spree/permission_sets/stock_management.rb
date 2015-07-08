module Spree
  module PermissionSets
    class StockManagement < PermissionSets::Base
      def activate!
        can :manage, Spree::StockItem
        can :manage, Spree::StockTransfer
        can :manage, Spree::TransferItem
      end
    end
  end
end
