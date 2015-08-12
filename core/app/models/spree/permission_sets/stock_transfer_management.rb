module Spree
  module PermissionSets
    class StockTransferManagement < PermissionSets::Base
      def activate!
        can :manage, Spree::StockTransfer
        can :manage, Spree::TransferItem
      end
    end
  end
end
