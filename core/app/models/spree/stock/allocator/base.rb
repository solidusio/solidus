# frozen_string_literal: true

module Spree
  module Stock
    module Allocator
      class Base
        attr_reader :availability, :coordinator_options

        def initialize(availability, coordinator_options: {})
          @availability = availability
          @coordinator_options = coordinator_options
        end

        def allocate_inventory(_desired)
          raise NotImplementedError
        end
      end
    end
  end
end
