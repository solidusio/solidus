# frozen_string_literal: true

module Spree
  module Stock
    module LocationFilter
      # This stock location filter return all active stock locations
      class Active < Spree::Stock::LocationFilter::Base
        def filter
          stock_locations.active
        end
      end
    end
  end
end
