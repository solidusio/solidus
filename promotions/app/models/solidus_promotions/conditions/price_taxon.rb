# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    class PriceTaxon < Condition
      include TaxonCondition

      MATCH_POLICIES = %w[include exclude].freeze

      validates :preferred_match_policy, inclusion: { in: MATCH_POLICIES }

      preference :match_policy, :string, default: MATCH_POLICIES.first

      def price_eligible?(price, _options = {})
        price_taxon_ids = price.variant.product.classifications.map(&:taxon_id)

        case preferred_match_policy
        when "include"
          taxon_ids_with_children.any? { |taxon_and_descendant_ids| (price_taxon_ids & taxon_and_descendant_ids).any? }
        when "exclude"
          taxon_ids_with_children.none? { |taxon_and_descendant_ids| (price_taxon_ids & taxon_and_descendant_ids).any? }
        else
          raise "unexpected match policy: #{preferred_match_policy.inspect}"
        end
      end
    end
  end
end
