# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    class OrderTaxon < Condition
      include TaxonCondition

      MATCH_POLICIES = %w[any all none].freeze

      validates :preferred_match_policy, inclusion: { in: MATCH_POLICIES }

      preference :match_policy, :string, default: MATCH_POLICIES.first

      def order_eligible?(order, _options = {})
        line_item_taxon_ids = taxon_ids_in_order(order)

        case preferred_match_policy
        when "all"
          unless taxon_ids_with_children.all? { |taxon_and_descendant_ids| (line_item_taxon_ids & taxon_and_descendant_ids).any? }

            eligibility_errors.add(:base, eligibility_error_message(:missing_taxon), error_code: :missing_taxon)
          end
        when "any"
          if taxon_ids_with_children.none? { |taxon_and_descendant_ids| (line_item_taxon_ids & taxon_and_descendant_ids).any? }

            eligibility_errors.add(
              :base,
              eligibility_error_message(:no_matching_taxons),
              error_code: :no_matching_taxons
            )
          end
        when "none"
          if taxon_ids_with_children.any? { |taxon_and_descendant_ids| (line_item_taxon_ids & taxon_and_descendant_ids).any? }

            eligibility_errors.add(
              :base,
              eligibility_error_message(:has_excluded_taxon),
              error_code: :has_excluded_taxon
            )
          end
        end

        eligibility_errors.empty?
      end

      def to_partial_path
        "solidus_promotions/admin/condition_fields/taxon"
      end

      private

      # All taxon IDs in an order
      def taxon_ids_in_order(order)
        order.line_items.flat_map do |line_item|
          line_item.variant.product.classifications.map(&:taxon_id)
        end
      end
    end
  end
end
