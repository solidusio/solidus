module Spree
  module PermissionSets
    # This is a permission set that offers an alternative to {StockManagement}.
    #
    # Instead of allowing management access for all stock transfers and items, only allow
    # the management of stock transfers for locations the user is associated with.
    #
    # Users can be associated with stock locations via the admin user interface.
    #
    # The logic here is unfortunately rather complex and boils down to:
    # - A user has read only access to all stock locations (including inactive ones)
    # - A user can see all stock transfers for their associated stock locations regardless of the
    #   fact that they may not be associated with both the destination and the source, as long as
    #   they are associated with at least one of the two.
    # - A user can manage stock transfers only if they are associated with both the destination and the source,
    #   or if the user is associated with the source, and the transfer has not yet been assigned a destination.
    #
    # @see Spree::PermissionSets::Base
    class RestrictedStockTransferManagement < PermissionSets::Base
      def activate!
        if user.stock_locations.any?
          can :display, Spree::StockLocation, id: user_location_ids

          can :transfer_from, Spree::StockLocation, id: user_location_ids
          can :transfer_to, Spree::StockLocation, id: user_location_ids

          can :display, Spree::StockTransfer, source_location_id: user_location_ids
          can :manage, Spree::StockTransfer, source_location_id: user_location_ids + [nil], shipped_at: nil
          can :manage, Spree::StockTransfer, destination_location_id: user_location_ids
          # Do not allow managing transfers to a permitted destination_location_id from an
          # unauthorized stock location until it's been shipped to the permitted location.
          cannot :manage, Spree::StockTransfer, source_location_id: not_permitted_location_ids, shipped_at: nil

          can :display, Spree::TransferItem, stock_transfer: { source_location_id: user_location_ids }
          can :manage, Spree::TransferItem, stock_transfer: { source_location_id: user_location_ids + [nil], shipped_at: nil }
          can :manage, Spree::TransferItem, stock_transfer: { destination_location_id: user_location_ids }
          cannot :manage, Spree::TransferItem, stock_transfer: { source_location_id: not_permitted_location_ids, shipped_at: nil }
        end
      end

      private

      def user_location_ids
        @user_location_ids ||= user.stock_locations.pluck(:id)
      end

      def not_permitted_location_ids
        @not_permitted_location_ids ||= Spree::StockLocation.where.not(id: user_location_ids).pluck(:id)
      end
    end
  end
end
