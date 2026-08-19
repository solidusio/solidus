# frozen_string_literal: true

module Spree
  module Stock
    class Coordinator
      attr_reader :order

      # @api private
      attr_reader :inventory_units, :splitters, :stock_locations

      def initialize(
        order,
        inventory_units: nil,
        inventory_unit_builder_class: Spree::Config.stock.inventory_unit_builder_class,
        splitters: Spree::Config.environment.stock_splitters,
        allocator_class: Spree::Config.stock.allocator_class,
        estimator_class: Spree::Config.stock.estimator_class,
        stock_locations: Spree::StockLocation.all
      )
        @order = order
        @inventory_units = inventory_units
        @stock_locations = stock_locations

        @inventory_unit_builder_class = inventory_unit_builder_class
        @allocator_class = allocator_class

        @estimator = estimator_class.new

        @splitters = splitters
      end

      def shipments
        @shipments ||= begin
          packages = build_packages
          packages = split_packages(packages)
          shipments = build_shipments(packages)

          # Make sure we don't add the proposed shipments to the order
          order.shipments = order.shipments - shipments

          shipments
        end
      end

      private

      def build_shipments(packages)
        # Turn the Stock::Packages into a Shipment with rates
        packages.map do |package|
          shipment = package.shipment = package.to_shipment
          shipment.shipping_rates = @estimator.shipping_rates(package)
          shipment
        end
      end

      def build_packages
        @inventory_units ||= @inventory_unit_builder_class.new(order).units

        @inventory_units_by_variant = @inventory_units.group_by(&:variant)
        desired = Spree::StockQuantities.new(@inventory_units_by_variant.transform_values(&:count))
        availability = Spree::Stock::Availability.new(
          variants: desired.variants,
          stock_locations:
        )
        allocator = @allocator_class.new(availability)

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
          @inventory_units_by_variant[variant].shift(quantity)
        end
      end
    end
  end
end

