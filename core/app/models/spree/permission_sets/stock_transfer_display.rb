module Spree
  module PermissionSets
    class StockTransferDisplay < PermissionSets::Base
      def activate!
        can [:display, :admin], Spree::StockTransfer
      end
    end
  end
end
