# frozen_string_literal: true

module Spree
  module Stock
    module Allocator
      class OnHandFirst < Spree::Stock::Allocator::Base
        def allocate_inventory(desired)
          # Allocate any available on hand inventory
          on_hand = allocate_on_hand(desired)
          desired -= on_hand.values.sum if on_hand.present?

          # Allocate remaining desired inventory from backorders
          backordered = allocate_backordered(desired)
          desired -= backordered.values.sum if backordered.present?

          # If all works at this point desired must be empty
          [on_hand, backordered, desired]
        end

        protected

        def allocate_on_hand(desired)
          allocate(availability.on_hand_by_stock_location_id, desired)
        end

        def allocate_backordered(desired)
          allocate(availability.backorderable_by_stock_location_id, desired)
        end

        def allocate(availability_by_location, desired)
          availability_by_location.transform_values do |available|
            # Find the desired inventory which is available at this location
            packaged = available & desired
            # Remove found inventory from desired
            desired -= packaged
            packaged
          end
        end
      end
    end
  end
end
