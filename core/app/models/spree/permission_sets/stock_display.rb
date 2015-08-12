module Spree
  module PermissionSets
    class StockDisplay < PermissionSets::Base
      def activate!
        can [:display, :admin], Spree::StockItem
      end
    end
  end
end
