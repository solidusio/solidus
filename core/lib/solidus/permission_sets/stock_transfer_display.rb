module Spree
  module PermissionSets
    class StockTransferDisplay < PermissionSets::Base
      def activate!
        can [:display, :admin], Solidus::StockTransfer
        can :display, Solidus::StockLocation
      end
    end
  end
end
