# frozen_string_literal: true

module SolidusPromotions
  module Calculators
    class PercentWithCap < Percent
      preference :max_amount, :integer, default: 100

      def compute(line_item)
        percent_discount = super
        max_discount = DistributedAmount.new(
          calculable:,
          preferred_amount: preferred_max_amount
        ).compute_line_item(line_item)

        [percent_discount, max_discount].min
      end
    end
  end
end
