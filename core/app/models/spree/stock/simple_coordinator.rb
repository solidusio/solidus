# frozen_string_literal: true

module Spree
  module Stock
    # A simple implementation of Stock Coordination
    #
    # The algorithm for allocating inventory is naive:
    #   * For each available Stock Location
    #     * Allocate as much on hand inventory as possible from this location
    #     * Remove the amount allocated from the amount desired
    #   * Repeat but for backordered inventory
    #   * Combine allocated and on hand inventory into a single shipment per-location
    #
    # Allocation logic can be changed using a custom class (as
    # configured in Spree::Config::stock_allocator_class )
    #
    # After allocation, splitters are run on each Package (as configured in
    # Spree::Config.environment.stock_splitters)
    #
    # Finally, shipping rates are calculated using the class configured as
    # Spree::Config.stock.estimator_class.
    class SimpleCoordinator
      attr_reader :order

      # @api private
      attr_reader :inventory_units, :splitters, :stock_locations,
        :filtered_stock_locations, :inventory_units_by_variant, :desired,
        :availability, :allocator, :packages

      def initialize(order, inventory_units = nil)
        @order = order
        @inventory_units =
          inventory_units || Spree::Config.stock.inventory_unit_builder_class.new(order).units
        @splitters = Spree::Config.environment.stock_splitters

        @filtered_stock_locations = Spree::Config.stock.location_filter_class.new(load_stock_locations, order).filter
        sorted_stock_locations = Spree::Config.stock.location_sorter_class.new(filtered_stock_locations).sort
        @stock_locations = sorted_stock_locations

        @inventory_units_by_variant = @inventory_units.group_by(&:variant)
        @desired = Spree::StockQuantities.new(inventory_units_by_variant.transform_values(&:count))
        @availability = Spree::Stock::Availability.new(
          variants: desired.variants,
          stock_locations: stock_locations
        )

        @allocator = Spree::Config.stock.allocator_class.new(availability)
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
          shipment.shipping_rates = Spree::Config.stock.estimator_class.new.shipping_rates(package)
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
