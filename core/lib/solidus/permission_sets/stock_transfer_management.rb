module Solidus
  module PermissionSets
    class StockTransferManagement < PermissionSets::Base
      def activate!
        can :manage, Solidus::StockTransfer
        can :manage, Solidus::TransferItem
        can :display, Solidus::StockLocation
      end
    end
  end
end
