# frozen_string_literal: true

module Spree
  module Stock
    class Coordinator
      def initialize(order, inventory_units: nil)
        context = {order:, inventory_units:}
        @order = order

        Middleware::InventoryUnit.new.call(context)
        @inventory_units = context[:inventory_units]

        Middleware::InventoryUnitGroup.new.call(context)
        @inventory_unit_groups = context[:inventory_unit_groups]

        @splitters = Spree::Config.environment.stock_splitters

        Middleware::StockLocation.new.call(context)
        @stock_locations = context[:stock_locations]

        Middleware::Desired.new.call(context)
        @desired = context[:desired]

        @availability = Spree::Stock::Availability.new(
          variants: @desired.variants,
          stock_locations: @stock_locations
        )

        @allocator = Spree::Config.stock.allocator_class.new(@availability)
      end

      def shipments
        @shipments ||= begin
                         @packages = build_packages
                         shipments = build_shipments

                         # Make sure we don't add the proposed shipments to the order
                         @order.shipments = @order.shipments - shipments

                         shipments
                       end
      end

      private

      def build_shipments
        # Turn the Stock::Packages into a Shipment with rates
        @packages.map do |package|
          shipment = package.shipment = package.to_shipment
          shipment.shipping_rates = Spree::Config.stock.estimator_class.new.shipping_rates(package)
          shipment
        end
      end

      def build_packages
        # Allocate any available on hand inventory and remaining desired inventory from backorders
        on_hand_packages, backordered_packages, leftover = @allocator.allocate_inventory(@desired)

        raise Spree::Order::InsufficientStock.new(items: leftover.quantities) unless leftover.empty?

        packages = @stock_locations.map do |stock_location|
          # Combine on_hand and backorders into a single package per-location
          on_hand = on_hand_packages[stock_location.id] || Spree::StockQuantities.new
          backordered = backordered_packages[stock_location.id] || Spree::StockQuantities.new

          # Skip this location it has no inventory
          next if on_hand.empty? && backordered.empty?

          # Turn our raw quantities into a Stock::Package
          package = Spree::Stock::Package.new(stock_location)
          package.add_multiple(get_units(on_hand), :on_hand)
          package.add_multiple(get_units(backordered), :backordered)

          package
        end.compact

        # Split the packages
        split_packages(packages)
      end

      def split_packages(initial_packages)
        initial_packages.flat_map do |initial_package|
          stock_location = initial_package.stock_location
          Spree::Stock::SplitterChain.new(stock_location, @splitters).split([initial_package])
        end
      end

      def get_units(quantities)
        # Change our raw quantities back into inventory units
        quantities.flat_map do |variant, quantity|
          @inventory_unit_groups[variant].shift(quantity)
        end
      end

    end
  end
end

