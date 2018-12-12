# frozen_string_literal: true

module Spree
  module Stock
    module Allocator
      class Base
        attr_reader :availability

        def initialize(availability)
          @availability = availability
        end

        def allocate_inventory(_desired)
          raise NotImplementedError
        end
      end
    end
  end
end
