# frozen_string_literal: true

module Spree
  module Stock
    class Coordinator
      attr_reader :order

      # @api private
      attr_reader :inventory_units, :splitters, :stock_locations,
        :filtered_stock_locations, :inventory_units_by_variant, :desired,
        :availability, :allocator, :packages

      def initialize(
        order,
        inventory_units: nil,
        inventory_unit_builder_class: Spree::Config.stock.inventory_unit_builder_class,
        splitters: Spree::Config.environment.stock_splitters,
        location_filter_class: Spree::Config.stock.location_filter_class,
        location_sorter_class: Spree::Config.stock.location_sorter_class,
        allocator_class: Spree::Config.stock.allocator_class,
        estimator_class: Spree::Config.stock.estimator_class
      )
        @order = order
        @inventory_units =
          inventory_units || inventory_unit_builder_class.new(order).units
        @splitters = splitters

        @filtered_stock_locations = location_filter_class.new(load_stock_locations, order).filter
        sorted_stock_locations = location_sorter_class.new(filtered_stock_locations).sort
        @stock_locations = sorted_stock_locations

        @inventory_units_by_variant = @inventory_units.group_by(&:variant)
        @desired = Spree::StockQuantities.new(inventory_units_by_variant.transform_values(&:count))
        @availability = Spree::Stock::Availability.new(
          variants: desired.variants,
          stock_locations:
        )

        @allocator = allocator_class.new(availability)
        @estimator = estimator_class.new
      end

      def shipments
        @shipments ||= begin
          @packages = build_packages
          shipments = build_shipments

          # Make sure we don't add the proposed shipments to the order
          order.shipments = order.shipments - shipments

          shipments
        end
      end

      private

      def load_stock_locations
        Spree::StockLocation.all
      end

      def build_shipments
        # Turn the Stock::Packages into a Shipment with rates
        packages.map do |package|
          shipment = package.shipment = package.to_shipment
          shipment.shipping_rates = @estimator.shipping_rates(package)
          shipment
        end
      end

      def build_packages
        # Allocate any available on hand inventory and remaining desired inventory from backorders
        on_hand_packages, backordered_packages, leftover = allocator.allocate_inventory(desired)

        raise Spree::Order::InsufficientStock.new(items: leftover.quantities) unless leftover.empty?

        packages = stock_locations.map do |stock_location|
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
          inventory_units_by_variant[variant].shift(quantity)
        end
      end
    end
  end
end

