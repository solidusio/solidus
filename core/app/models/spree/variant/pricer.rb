module Spree
  class Variant
    class Pricer
      attr_reader :variant

      def initialize(variant)
        @variant = variant
      end

      def price_for(options)
      end
    end
  end
end
