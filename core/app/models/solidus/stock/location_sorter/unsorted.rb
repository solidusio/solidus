# frozen_string_literal: true

module Solidus
  module Stock
    module LocationSorter
      # This stock location sorter will leave the stock locations unsorted.
      class Unsorted < Solidus::Stock::LocationSorter::Base
        def sort
          stock_locations
        end
      end
    end
  end
end
