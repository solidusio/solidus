# frozen_string_literal: true

module Spree
  module Stock
    module LocationSorter
      # Stock location sorters are used to determine the order in which
      # inventory units will be allocated when packaging a shipment.
      #
      # This allows you, for example, to allocate inventory from the default
      # stock location first.
      #
      # @abstract To implement your own location sorter, subclass and
      #   implement {#sort}.
      class Base
        # @!attribute [r] stock_locations
        #   @return [Enumerable<Spree::StockLocation>]
        #     a collection of locations to sort
        attr_reader :stock_locations

        # Initializes the stock location sorter.
        #
        # @param stock_locations [Enumerable<Spree::StockLocation>]
        #   a collection of locations to sort
        def initialize(stock_locations)
          @stock_locations = stock_locations
        end

        # Sorts the stock locations.
        #
        # @return [Enumerable<Spree::StockLocation>]
        #   a collection of sorted stock locations
        def sort
          raise NotImplementedError
        end
      end
    end
  end
end
