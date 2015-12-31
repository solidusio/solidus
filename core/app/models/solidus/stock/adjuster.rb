module Spree
  module Stock
    # Used by Prioritizer to adjust item quantities.
    #
    # See spec/models/spree/stock/prioritizer_spec.rb for use cases.
    class Adjuster
      attr_accessor :inventory_unit, :status, :fulfilled

      def initialize(inventory_unit, status)
        @inventory_unit = inventory_unit
        @status = status
        @fulfilled = false
      end

      def adjust(package)
        if fulfilled?
          package.remove(inventory_unit)
        else
          self.fulfilled = true
        end
      end

      def fulfilled?
        fulfilled
      end
    end
  end
end
