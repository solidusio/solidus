# frozen_string_literal: true

module Solidus
  module Stock
    module LocationFilter
      # Stock location filters are used to which stock location should be
      # considered when allocating stocks for a new shipment
      #
      # @abstract To implement your own location filter, subclass and
      #   implement {#filter}.
      class Base
        # @!attribute [r] stock_locations
        #   @return [Enumerable<Solidus::StockLocation>]
        #     a collection of locations to sort
        attr_reader :stock_locations

        # @!attribute [r] order
        #   @return <Solidus::Order>
        #     the order we are creating the shipment for
        attr_reader :order

        # Initializes the stock location filter.
        #
        # @param stock_locations [Enumerable<Solidus::StockLocation>]
        #   a collection of locations to sort
        # @param order <Solidus::Order>
        #   the order we are creating the shipment for
        def initialize(stock_locations, order)
          @stock_locations = stock_locations
          @order = order
        end

        # Filter the stock locations.
        #
        # @return [Enumerable<Solidus::StockLocation>]
        #   a collection of filtered stock locations
        def filter
          raise NotImplementedError
        end
      end
    end
  end
end
