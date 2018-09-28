# frozen_string_literal: true

module Spree
  module Stock
    module LocationSorter
      # This stock location sorter will give priority to the default stock
      # location.
      class DefaultFirst < Spree::Stock::LocationSorter::Base
        def sort
          stock_locations.order_default
        end
      end
    end
  end
end
