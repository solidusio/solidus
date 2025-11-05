# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    # A condition to apply a promotion only to line items with or without a chosen product
    class LineItemProduct < Condition
      # TODO: Remove in Solidus 5
      include LineItemLevelCondition

      include ProductCondition

      MATCH_POLICIES = %w[include exclude].freeze

      preference :match_policy, :string, default: MATCH_POLICIES.first

      def line_item_eligible?(line_item, _options = {})
        order_includes_product = product_ids.include?(line_item.variant.product_id)
        success = inverse? ? !order_includes_product : order_includes_product

        unless success
          message_code = inverse? ? :has_excluded_product : :no_applicable_products
          eligibility_errors.add(
            :base,
            eligibility_error_message(message_code),
            error_code: message_code
          )
        end

        success
      end

      private

      def inverse?
        preferred_match_policy == "exclude"
      end
    end
  end
end
