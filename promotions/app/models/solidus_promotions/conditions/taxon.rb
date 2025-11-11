# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    class Taxon < Condition
      include LineItemApplicableOrderLevelCondition

      include TaxonCondition

      MATCH_POLICIES = %w[any all none].freeze

      validates :preferred_match_policy, inclusion: { in: MATCH_POLICIES }

      preference :match_policy, :string, default: MATCH_POLICIES.first

      def order_eligible?(order, _options = {})
        order_condition = OrderTaxon.new(taxons:, preferred_match_policy:)
        order_condition.order_eligible?(order)
        @eligibility_errors = order_condition.eligibility_errors
        eligibility_errors.empty?
      end

      def line_item_eligible?(line_item, _options = {})
        line_item_match_policy = preferred_match_policy.in?(%w[any all]) ? "include" : "exclude"
        line_item_condition = LineItemTaxon.new(taxons:, preferred_match_policy: line_item_match_policy)
        result = line_item_condition.line_item_eligible?(line_item)
        @eligibility_errors = line_item_condition.eligibility_errors
        result
      end
    end
  end
end
