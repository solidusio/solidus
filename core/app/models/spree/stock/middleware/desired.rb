module Spree
  module Stock
    module Middleware
      class Desired
        def call(context)
          context[:desired] = Spree::StockQuantities.new(context[:inventory_unit_groups].transform_values(&:count))
        end
      end
    end
  end
end
