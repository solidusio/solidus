module Spree
  module PermissionSets
    class StockDisplay < PermissionSets::Base
      def activate!
        can [:display, :admin], Spree::StockItem
        can [:display, :admin], Spree::StockTransfer
      end
    end
  end
end
