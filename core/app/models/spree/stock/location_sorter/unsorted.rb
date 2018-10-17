# frozen_string_literal: true

module Spree
  module Stock
    module LocationSorter
      # This stock location sorter will leave the stock locations unsorted.
      class Unsorted < Spree::Stock::LocationSorter::Base
        def sort
          stock_locations
        end
      end
    end
  end
end
