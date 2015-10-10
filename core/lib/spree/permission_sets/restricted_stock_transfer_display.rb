module Spree
  module PermissionSets
    class RestrictedStockTransferDisplay < PermissionSets::Base
      def activate!
        can [:display, :admin], Spree::StockTransfer, source_location_id: location_ids
        can [:display, :admin], Spree::StockTransfer, destination_location_id: location_ids
        can :display, Spree::StockLocation, id: location_ids
      end

      private

      def location_ids
        @ids ||= user.stock_locations.pluck(:id)
      end
    end
  end
end
