module Spree
  module PermissionSets
    class StockTransferManagement < PermissionSets::Base
      def activate!
        can :manage, Spree::StockTransfer
        can :manage, Spree::TransferItem
        can :display, Spree::StockLocation
      end
    end
  end
end
