# frozen_string_literal: true

module SolidusPromotions
  module Benefits
    class AdjustPrice < Benefit
      def can_discount?(object)
        object.is_a?(Spree::LineItem) || object.is_a?(Spree::Price)
      end

      def possible_conditions
        super + SolidusPromotions.config.price_conditions
      end

      def level
        :line_item
      end
    end
  end
end
