# frozen_string_literal: true

module Spree
  module PermissionSets
    class RestrictedStockManagement < PermissionSets::Base
      def activate!
        can :manage, Spree::StockItem, stock_location_id: location_ids
        can :display, Spree::StockLocation, id: location_ids
      end

      private

      def location_ids
        @ids ||= user.stock_locations.pluck(:id)
      end
    end
  end
end
