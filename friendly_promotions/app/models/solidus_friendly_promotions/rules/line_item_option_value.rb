# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Rules
    class LineItemOptionValue < PromotionRule
      preference :eligible_values, :hash

      def applicable?(promotable)
        promotable.is_a?(Discountable::LineItem)
      end

      def eligible?(line_item, _options = {})
        pid = line_item.product.id
        ovids = line_item.variant.option_values.pluck(:id)

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
