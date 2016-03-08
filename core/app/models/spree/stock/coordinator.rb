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
        packages.map(&:shipment)
      end

      private

      def packages
        packages = build_location_configured_packages
        packages = build_packages(packages)
        packages = prioritize_packages(packages)
        packages.each do |package|
          package.shipment = package.to_shipment
        end
        packages = estimate_packages(packages)
        validate_packages(packages)
        packages
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
      def build_location_configured_packages(packages = [])
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
      def build_packages(packages = [])
        stock_location_variant_ids.each do |stock_location, variant_ids|
          units_for_location = unallocated_inventory_units.select { |unit| variant_ids.include?(unit.variant_id) }
          packer = build_packer(stock_location, units_for_location)
          packages += packer.packages
        end
        packages
      end

      # This finds the variants we're looking for in each active stock location.
      # It returns a hash like:
      #   {
      #     <stock location> => <set of variant ids>,
      #     <stock location> => <set of variant ids>,
      #     ...,
      #   }
      # This is done in an awkward way for performance reasons.  It uses two
      # queries that are kept as performant as possible, and only loads the
      # minimum required ActiveRecord objects.
      def stock_location_variant_ids
        # associate the variant ids we're interested in with stock location ids
        location_variant_ids = StockItem.
          where(variant_id: unallocated_variant_ids).
          joins(:stock_location).
          merge(StockLocation.active).
          pluck(:stock_location_id, :variant_id)

        # load activerecord objects for the stock location ids and turn them
        # into a lookup hash like:
        #   {
        #     <stock location id> => <stock location>,
        #     ...,
        #   }
        location_lookup = StockLocation.
          where(id: location_variant_ids.map(&:first).uniq).
          map { |l| [l.id, l] }.
          to_h

        # build the final lookup hash of
        #   {<stock location> => <set of variant ids>, ...}
        # using the previous results
        location_variant_ids.each_with_object({}) do |(location_id, variant_id), hash|
          location = location_lookup[location_id]
          hash[location] ||= Set.new
          hash[location] << variant_id
        end
      end

      def unallocated_inventory_units
        inventory_units - @preallocated_inventory_units
      end

      def unallocated_variant_ids
        unallocated_inventory_units.map(&:variant_id).uniq
      end

      def prioritize_packages(packages)
        prioritizer = Prioritizer.new(inventory_units, packages)
        prioritizer.prioritized_packages
      end

      def estimate_packages(packages)
        estimator = Spree::Config.stock.estimator_class.new
        packages.each do |package|
          package.shipment.shipping_rates = estimator.shipping_rates(package)
        end
        packages
      end

      def validate_packages(packages)
        desired_quantity = inventory_units.size
        packaged_quantity = packages.sum(&:quantity)
        if packaged_quantity != desired_quantity
          raise Spree::Order::InsufficientStock,
            "Was only able to package #{packaged_quantity} inventory units of #{desired_quantity} requested"
        end
      end

      def build_packer(stock_location, inventory_units)
        Packer.new(stock_location, inventory_units, splitters(stock_location))
      end

      def splitters(_stock_location)
        # extension point to return custom splitters for a location
        Rails.application.config.spree.stock_splitters
      end
    end
  end
end
