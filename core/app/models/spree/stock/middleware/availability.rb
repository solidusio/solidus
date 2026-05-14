module Spree
  module Stock
    module Middleware
      class Availability
        def call(context)
          context[:availability] = Spree::Stock::Availability.new(
            variants: context[:desired].variants,
            stock_locations: context[:stock_locations]
          )
        end
      end
    end
  end
end
