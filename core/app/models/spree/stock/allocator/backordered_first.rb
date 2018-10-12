# frozen_string_literal: true

module Spree
  module Stock
    module Allocator
      class BackorderedFirst < Spree::Stock::Allocator::Base
        def allocate_inventory(desired)
          on_hand, remaining = allocate(availability.on_hand_by_stock_location_id, desired)
          backordered, leftovers = allocate(availability.backorderable_by_stock_location_id, remaining)
          [on_hand, backordered, leftovers]
        end

        protected

        def allocate(availability_by_location, desired)
          remaining = desired.dup
          available_by_location = {}
          availability_by_location.each do |stock_location_id, available|
            stock_location = Spree::StockLocation.find(stock_location_id)

            # If the default stock location hasn't enough stock_items remove the
            # availability to remove all the desired quantities from the others stock location
            available = remove_availability_if_not_enough(available, remaining) if stock_location.default?

            # Find the desired inventory which is available at this location
            packaged = available & remaining
            available_by_location[stock_location_id] = packaged

            # Remove found inventory from remaining
            remaining -= packaged
          end

          [available_by_location, remaining]
        end

        def remove_availability_if_not_enough(available, remaining)
          quantities = {}
          (available - remaining).each do |variant, quantity|
            quantities[variant] = quantity.negative? ? 0 : (available.quantities[variant] || 0)
          end
          Spree::StockQuantities.new(quantities)
        end
      end
    end
  end
end
