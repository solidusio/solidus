module Spree
  module Stock
    class Coordinator
      attr_reader :order, :inventory_units

      def initialize(order, inventory_units = nil)
        @order = order
        @inventory_units = inventory_units || InventoryUnitBuilder.new(order).units
        @preallocated_inventory_units = []
      end

      def shipments
        packages.map do |package|
          package.to_shipment.tap { |s| s.address = order.ship_address }
        end
      end

      def packages
        packages = build_location_configured_packages
        packages = build_packages(packages)
        packages = prioritize_packages(packages)
        packages = estimate_packages(packages)
      end

      # Build packages for the inventory units that have preferred stock locations first
      #
      # Certain variants have been selected to be fulfilled from a particular stock
      # location during the process of the order being created. The rest of the
      # service objects the coordinator uses do a lot of automated logic to
      # determine which stock location is best for the inventory unit to be
      # fulfilled from, but for these special snowflakes we KNOW which stock
      # location they should be fulfilled from. So rather than sending these units
      # through the rest of the packing / prioritization, lets just put them
      # in packages we know they should be in and deal with other automatically-
      # handled inventory units otherwise.
      def build_location_configured_packages(packages = Array.new)
        order.order_stock_locations.where(shipment_fulfilled: false).group_by(&:stock_location).each do |stock_location, stock_location_configurations|
          units = stock_location_configurations.flat_map do |stock_location_configuration|
            unallocated_inventory_units.select { |iu| iu.variant == stock_location_configuration.variant }.take(stock_location_configuration.quantity)
          end
          packer = build_packer(stock_location, units)
          packages += packer.packages
          @preallocated_inventory_units += units
        end
        packages
      end

      # Build packages as per stock location
      #
      # It needs to check whether each stock location holds at least one stock
      # item for the order. In case none is found it wouldn't make any sense
      # to build a package because it would be empty. Plus we avoid errors down
      # the stack because it would assume the stock location has stock items
      # for the given order
      #
      # Returns an array of Package instances
      def build_packages(packages = Array.new)
        requested_stock_items.group_by(&:stock_location).each do |stock_location, stock_items|
          variant_ids_in_stock_location = stock_items.map(&:variant_id)
          units_for_location = unallocated_inventory_units.select { |unit| variant_ids_in_stock_location.include?(unit.variant_id) }
          packer = build_packer(stock_location, units_for_location)
          packages += packer.packages
        end
        packages
      end

      private

      def unallocated_inventory_units
        inventory_units - @preallocated_inventory_units
      end

      def requested_stock_items
        Spree::StockItem.where(variant_id: unallocated_variant_ids).joins(:stock_location).merge(StockLocation.active).includes(:stock_location)
      end

      def unallocated_variant_ids
        unallocated_inventory_units.map(&:variant_id).uniq
      end

      def prioritize_packages(packages)
        prioritizer = Prioritizer.new(inventory_units, packages)
        prioritizer.prioritized_packages
      end

      def estimate_packages(packages)
        estimator = Estimator.new(order)
        packages.each do |package|
          package.shipping_rates = estimator.shipping_rates(package)
        end
        packages
      end

      def build_packer(stock_location, inventory_units)
        Packer.new(stock_location, inventory_units, splitters(stock_location))
      end

      def splitters(stock_location)
        # extension point to return custom splitters for a location
        Rails.application.config.spree.stock_splitters
      end
    end
  end
end
