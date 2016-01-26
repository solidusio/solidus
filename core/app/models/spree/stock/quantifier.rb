module Spree
  module Stock
    class Quantifier
      attr_reader :stock_items

      def initialize(variant, stock_location = nil)
        @variant = variant
        where_args = { variant_id: @variant }
        if stock_location
          where_args[:stock_location] = stock_location
        else
          where_args[Spree::StockLocation.table_name] = { active: true }
        end
        @stock_items = Spree::StockItem.joins(:stock_location).where(where_args)
      end

      # Returns the total number of inventory units on hand for the variant.
      #
      # @return [Fixnum] number of inventory units on hand, or infinity if
      #   inventory is not tracked on the variant.
      def total_on_hand
        if @variant.should_track_inventory?
          stock_items.sum(:count_on_hand)
        else
          Float::INFINITY
        end
      end

      # Checks if any of its stock items are backorderable.
      #
      # @return [Boolean] true if any stock items are backorderable
      def backorderable?
        stock_items.any?(&:backorderable)
      end

      # Checks if it is possible to supply a given number of units.
      #
      # @param required [Fixnum] the number of required stock units
      # @return [Boolean] true if we have the required amount on hand or the
      #   variant is backorderable, otherwise false
      def can_supply?(required)
        total_on_hand >= required || backorderable?
      end
    end
  end
end
