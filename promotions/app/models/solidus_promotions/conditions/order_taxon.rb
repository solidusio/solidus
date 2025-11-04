# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    class OrderTaxon < Condition
      include TaxonCondition

      MATCH_POLICIES = %w[any all none].freeze

      validates :preferred_match_policy, inclusion: { in: MATCH_POLICIES }

      preference :match_policy, :string, default: MATCH_POLICIES.first

      def order_eligible?(order, _options = {})
        order_taxons = taxons_in_order(order)

        case preferred_match_policy
        when "all"
          matches_all = taxons.all? do |condition_taxon|
            order_taxons.where(id: condition_taxon.self_and_descendants.ids).exists?
          end

          unless matches_all
            eligibility_errors.add(:base, eligibility_error_message(:missing_taxon), error_code: :missing_taxon)
          end
        when "any"
          unless order_taxons.where(id: condition_taxon_ids_with_children).exists?
            eligibility_errors.add(
              :base,
              eligibility_error_message(:no_matching_taxons),
              error_code: :no_matching_taxons
            )
          end
        when "none"
          if order_taxons.where(id: condition_taxon_ids_with_children).exists?
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

      # All taxons in an order
      def taxons_in_order(order)
        Spree::Taxon
          .joins(products: { variants_including_master: :line_items })
          .where(spree_line_items: { order_id: order.id })
          .distinct
      end
    end
  end
end
