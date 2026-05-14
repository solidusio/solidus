module Spree
  module Stock
    module Middleware
      class StockLocation
        def call(context)
          filtered_stock_locations = Spree::Config.stock.location_filter_class.new(
            load_stock_locations, context[:order]
          ).filter
          sorted_stock_locations = Spree::Config.stock.location_sorter_class.new(
            filtered_stock_locations
          ).sort

          context[:stock_locations] = sorted_stock_locations
        end

        private

        def load_stock_locations
          Spree::StockLocation.all
        end
      end
    end
  end
end
