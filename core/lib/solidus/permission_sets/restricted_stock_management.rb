# frozen_string_literal: true

module Solidus
  module PermissionSets
    class RestrictedStockManagement < PermissionSets::Base
      def activate!
        can :manage, Solidus::StockItem, stock_location_id: location_ids
        can :display, Solidus::StockLocation, id: location_ids
      end

      private

      def location_ids
        @ids ||= user.stock_locations.pluck(:id)
      end
    end
  end
end
