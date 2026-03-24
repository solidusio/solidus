# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    # A condition to apply a promotion only to prices with or without selected products
    class PriceProduct < Condition
      include ProductCondition

      MATCH_POLICIES = %w[include exclude].freeze

      preference :match_policy, :string, default: MATCH_POLICIES.first

      def price_eligible?(price, _options = {})
        price_matches_products = products.include?(price.variant.product)
        success = exclude_configured_products? ? !price_matches_products : price_matches_products

        unless success
          message_code = exclude_configured_products? ? :has_excluded_product : :no_applicable_products
          eligibility_errors.add(
            :base,
            eligibility_error_message(message_code),
            error_code: message_code
          )
        end

        success
      end

      private

      def exclude_configured_products?
        preferred_match_policy == "exclude"
      end
    end
  end
end
