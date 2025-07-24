# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    class LineItemOptionValue < Condition
      include LineItemLevelCondition

      preference :eligible_values, :hash

      def eligible?(line_item_or_price, _options = {})
        pid = line_item_or_price.variant.product_id
        ovids = line_item_or_price.variant.option_values.pluck(:id)

        product_ids.include?(pid) && (value_ids(pid) & ovids).present?
      end

      def preferred_eligible_values
        values = preferences[:eligible_values] || {}
        values.keys.map(&:to_i).zip(
          values.values.map do |value|
            (value.is_a?(Array) ? value : value.split(",")).map(&:to_i)
          end
        ).to_h
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
