# frozen_string_literal: true

module SolidusPromotions
  module Calculators
    module PromotionCalculator
      def description
        self.class.human_attribute_name(:description)
      end

      private

      def round_to_currency(number, currency)
        currency_exponent = ::Money::Currency.find(currency).exponent
        number.round(currency_exponent)
      end

      def adjusted_amount_before_current_lane(item)
        item.adjusted_amount_by_lanes(promotion.previous_lanes)
      end

      delegate :promotion, to: :calculable
    end
  end
end
