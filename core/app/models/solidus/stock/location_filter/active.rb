# frozen_string_literal: true

module Solidus
  module Stock
    module LocationFilter
      # This stock location filter return all active stock locations
      class Active < Solidus::Stock::LocationFilter::Base
        def filter
          stock_locations.active
        end
      end
    end
  end
end
