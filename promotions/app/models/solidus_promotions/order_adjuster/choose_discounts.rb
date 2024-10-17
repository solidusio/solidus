# frozen_string_literal: true

module SolidusPromotions
  class OrderAdjuster
    class ChooseDiscounts
      attr_reader :discounts

      def initialize(discounts)
        @discounts = discounts
      end

      def call
        Array.wrap(
          discounts.min_by do |discount|
            [discount.amount, -discount.source&.id.to_i]
          end
        )
      end
    end
  end
end
