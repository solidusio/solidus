# frozen_string_literal: true

module Spree
  module Stock
    class Quantifier
      attr_reader :stock_items

      # @param [Variant] variant The variant to check inventory for.
      # @param [StockLocation, Integer] stock_location The stock_location to check inventory in. If unspecified it will check inventory in all available StockLocations
      def initialize(variant, stock_location = nil)
        @variant = variant
        @stock_items = Spree::StockItem.where(variant_id: variant)
        if stock_location
          @stock_items.where!(stock_location: stock_location)
        else
          @stock_items.joins!(:stock_location).merge!(Spree::StockLocation.active)
        end
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
