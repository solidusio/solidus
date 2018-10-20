# frozen_string_literal: true

module Spree
  module Admin
    module StockLocationsHelper
      def admin_stock_location_display_name(stock_location)
        name_parts = [stock_location.admin_name, stock_location.name]
        name_parts.delete_if(&:blank?)
        name_parts.join(' / ')
      end
    end
  end
end
