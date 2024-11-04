# frozen_string_literal: true

module SolidusPromotions
  module Benefits
    class AdjustLineItem < Benefit
      include SolidusPromotions::Benefits::LineItemBenefit

      def possible_conditions
        super + SolidusPromotions.config.line_item_conditions
      end
    end
  end
end
