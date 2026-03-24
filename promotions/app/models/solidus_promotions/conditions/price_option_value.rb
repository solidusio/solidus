# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    class PriceOptionValue < Condition
      include OptionValueCondition

      def price_eligible?(price, _options = {})
        pid = price.variant.product_id
        ovids = price.variant.option_value_ids

        product_ids.include?(pid) && (value_ids(pid) & ovids).present?
      end

      private

      def product_ids
        preferred_eligible_values.keys
      end

      def value_ids(product_id)
        preferred_eligible_values[product_id]
      end
    end
  end
end
