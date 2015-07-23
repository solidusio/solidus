module Spree
  module PermissionSets
    # This is a permission set that offers an alternative to {StockManagement}.
    #
    # Instead of allowing management access for all stock transfers and items, only allow
    # the management of stock transfers for locations the user is associated with.
    #
    # Users can be associated with stock locations via the admin user interface.
    #
    # @see Spree::PermissionSets::Base
    class RestrictedTransferManagement < PermissionSets::Base
      def activate!
        can [:display, :admin], Spree::StockItem
        can [:display, :admin], Spree::StockTransfer

        if user.stock_locations.any?
          can :transfer, Spree::StockLocation, id: location_ids
          can :update, Spree::StockItem, stock_location_id: location_ids
          can :manage, Spree::StockTransfer, source_location_id: location_ids, destination_location_id: location_ids
          can :manage, Spree::TransferItem, stock_transfer: {
            source_location_id: location_ids,
            destination_location_id: location_ids
          }
        end
      end

      private

      def location_ids
        # either source_location_id or destination_location_id can be nil.
        @ids ||= user.stock_locations.pluck(:id) + [nil]
      end
    end
  end
end
