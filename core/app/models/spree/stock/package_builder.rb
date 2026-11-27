# frozen_string_literal: true

module Spree
  module Stock
    class PackageBuilder
      def initialize(
        inventory_units:,
        stock_locations:,
        allocator_class: Spree::Config.stock.allocator_class
      )
        @inventory_units_by_variant = inventory_units.group_by(&:variant)
        @desired = Spree::StockQuantities.new(@inventory_units_by_variant.transform_values(&:count))

        @stock_locations = stock_locations

        availability = Spree::Stock::Availability.new(
          variants: @desired.variants,
          stock_locations: @stock_locations
        )
        @allocator = allocator_class.new(availability)
      end

      def call
        on_hand_packages, backordered_packages, leftover = @allocator.allocate_inventory(@desired)

        raise Spree::Order::InsufficientStock.new(items: leftover.quantities) unless leftover.empty?

        @stock_locations.map do |stock_location|
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

      private

      def get_units(quantities)
        # Change our raw quantities back into inventory units
        quantities.flat_map do |variant, quantity|
          @inventory_units_by_variant[variant].shift(quantity)
        end
      end
    end
  end
end
