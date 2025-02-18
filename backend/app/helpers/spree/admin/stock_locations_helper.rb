# frozen_string_literal: true

module Spree
  module Admin
    module StockLocationsHelper
      def admin_stock_location_display_name(stock_location)
        [stock_location.admin_name, stock_location.name].compact_blank.join(" / ")
      end
    end
  end
end
