module Spree
  module Stock
    class Packer
      attr_reader :stock_location, :inventory_units, :splitters

      def initialize(stock_location, inventory_units, splitters=[Splitter::Base])
        @stock_location = stock_location
        @inventory_units = inventory_units
        @splitters = splitters
      end

      def packages
        if splitters.empty?
          [default_package]
        else
          build_splitter.split [default_package]
        end
      end

      def default_package
        package = Package.new(stock_location)
        inventory_units.group_by(&:variant).each do |variant, variant_inventory_units|
          units = variant_inventory_units.clone
          if variant.should_track_inventory?
            stock_item = stock_item_lookup[variant.id]
            next unless stock_item

            on_hand, backordered = stock_item.fill_status(units.count)
            raise Spree::Order::InsufficientStock unless on_hand > 0 || backordered > 0
            package.add_multiple units.slice!(0, on_hand), :on_hand if on_hand > 0
            package.add_multiple units.slice!(0, backordered), :backordered if backordered > 0
          else
            package.add_multiple units
          end

        end
        package
      end

      private

      # Returns a lookup table in the form of:
      #   {<variant_id> => <stock_item>, ...}
      def stock_item_lookup
        @stock_item_lookup ||= begin
          Spree::StockItem.
            where(variant_id: inventory_units.map(&:variant_id).uniq).
            where(stock_location_id: stock_location.id).
            order(:id).
            each_with_object({}) do |stock_item, hash|
              hash[stock_item.variant_id] ||= stock_item
            end
        end
      end

      def build_splitter
        splitter = nil
        splitters.reverse.each do |klass|
          splitter = klass.new(self, splitter)
        end
        splitter
      end
    end
  end
end
