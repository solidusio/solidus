# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    # A condition to limit a promotion based on products in the order.  Can
    # require all or any of the products to be present.  Valid products
    # either come from assigned product group or are assingned directly to
    # the condition.
    class Product < Condition
      include LineItemApplicableOrderLevelCondition

      include ProductCondition

      MATCH_POLICIES = %w[any all none only].freeze

      validates :preferred_match_policy, inclusion: { in: MATCH_POLICIES }

      preference :match_policy, :string, default: MATCH_POLICIES.first

      def order_eligible?(order, _options = {})
        order_condition = OrderProduct.new(products:, preferred_match_policy:)
        order_condition.order_eligible?(order)
        @eligibility_errors = order_condition.eligibility_errors
        eligibility_errors.empty?
      end

      def line_item_eligible?(line_item, _options = {})
        line_item_match_policy = preferred_match_policy.in?(%w[any all only]) ? "include" : "exclude"
        line_item_condition = LineItemProduct.new(products:, preferred_match_policy: line_item_match_policy)
        line_item_condition.line_item_eligible?(line_item)
        @eligibility_errors = line_item_condition.eligibility_errors
        eligibility_errors.empty?
      end
    end
  end
end
