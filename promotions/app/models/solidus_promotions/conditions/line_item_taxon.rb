# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    class LineItemTaxon < Condition
      # TODO: Remove in Solidus 5
      include LineItemLevelCondition

      include TaxonCondition

      MATCH_POLICIES = %w[include exclude].freeze

      validates :preferred_match_policy, inclusion: { in: MATCH_POLICIES }

      preference :match_policy, :string, default: MATCH_POLICIES.first

      def line_item_eligible?(line_item, _options = {})
        found = Spree::Classification.where(
          product_id: line_item.variant.product_id,
          taxon_id: condition_taxon_ids_with_children
        ).exists?

        case preferred_match_policy
        when "include"
          found
        when "exclude"
          !found
        else
          raise "unexpected match policy: #{preferred_match_policy.inspect}"
        end
      end
    end
  end
end
