# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    class LineItemOptionValue < Condition
      # TODO: Remove in Solidus 5
      include LineItemLevelCondition

      include OptionValueCondition

      def line_item_eligible?(line_item, _options = {})
        pid = line_item.product.id
        ovids = line_item.variant.option_values.pluck(:id)

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
