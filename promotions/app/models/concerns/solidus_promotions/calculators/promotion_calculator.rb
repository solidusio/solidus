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
    end
  end
end
