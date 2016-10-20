module Spree
  class Calculator
    class PercentOnLineItem < Calculator
      preference :percent, :decimal, default: 0

      def compute(object)
        (object.amount * preferred_percent) / 100
      end
    end
  end
end
