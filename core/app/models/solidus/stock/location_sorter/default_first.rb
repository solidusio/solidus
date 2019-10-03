# frozen_string_literal: true

module Solidus
  module Stock
    module LocationSorter
      # This stock location sorter will give priority to the default stock
      # location.
      class DefaultFirst < Solidus::Stock::LocationSorter::Base
        def sort
          stock_locations.order_default
        end
      end
    end
  end
end
