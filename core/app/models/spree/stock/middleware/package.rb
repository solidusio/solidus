module Spree
  module Stock
    module Middleware
      class Package
        def call(context)
          packages = context.stock_locations.map do |stock_location|
            on_hand = context.on_hand_packages[stock_location.id] || Spree::StockQuantities.new
            backordered = context.backordered_packages[stock_location.id] || Spree::StockQuantities.new

            next if on_hand.empty? && backordered.empty?

            package = Spree::Stock::Package.new(stock_location)
            package.add_multiple(get_units(context, on_hand), :on_hand)
            package.add_multiple(get_units(context, backordered), :backordered)

            package
          end.compact

          context.packages = split_packages(packages)

          yield context
        end

        private

        def get_units(context, quantities)
          quantities.flat_map do |variant, quantity|
            context.inventory_unit_groups[variant].shift(quantity)
          end
        end

        def split_packages(initial_packages)
          splitters = Spree::Config.environment.stock_splitters

          initial_packages.flat_map do |initial_package|
            stock_location = initial_package.stock_location
            Spree::Stock::SplitterChain.new(stock_location, splitters).split([initial_package])
          end
        end
      end
    end
  end
end
