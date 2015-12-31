module Solidus
  module PermissionSets
    class RestrictedStockTransferDisplay < PermissionSets::Base
      def activate!
        can [:display, :admin], Solidus::StockTransfer, source_location_id: location_ids
        can [:display, :admin], Solidus::StockTransfer, destination_location_id: location_ids
        can :display, Solidus::StockLocation, id: location_ids
      end

      private

      def location_ids
        @ids ||= user.stock_locations.pluck(:id)
      end
    end
  end
end
