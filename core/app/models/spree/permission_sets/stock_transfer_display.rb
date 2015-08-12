module Spree
  module PermissionSets
    class StockTransferDisplay < PermissionSets::Base
      def activate!
        can [:display, :admin], Spree::StockTransfer
        can :display, Spree::StockLocation
      end
    end
  end
end
