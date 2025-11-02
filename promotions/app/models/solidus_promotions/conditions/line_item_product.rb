# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    # A condition to apply a promotion only to line items with or without a chosen product
    class LineItemProduct < Condition
      include LineItemLevelCondition

      MATCH_POLICIES = %w[include exclude].freeze

      has_many :condition_products,
        dependent: :destroy,
        foreign_key: :condition_id,
        class_name: "SolidusPromotions::ConditionProduct",
        inverse_of: :condition
      has_many :products,
        class_name: "Spree::Product",
        through: :condition_products

      preference :match_policy, :string, default: MATCH_POLICIES.first

      def preload_relations
        [:products]
      end

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

      def product_ids_string
        product_ids.join(",")
      end

      def product_ids_string=(product_ids)
        self.product_ids = product_ids.to_s.split(",").map(&:strip)
      end

      private

      def inverse?
        preferred_match_policy == "exclude"
      end
    end
  end
end
