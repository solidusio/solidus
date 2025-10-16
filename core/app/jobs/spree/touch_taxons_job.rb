# frozen_string_literal: true

module Spree
  class TouchTaxonsJob < BaseJob
    def perform(taxon_ids)
      return if taxon_ids.blank?

      # Single query to get originals + ancestors with their taxonomy IDs
      # Note: Original taxons are already touched by Rails, we only update ancestors
      all_taxon_and_taxonomy_ids = Spree::Taxon
        .where(id: taxon_ids)
        .or(
          Spree::Taxon.where(
            "EXISTS (
              SELECT 1 FROM spree_taxons AS targets
              WHERE targets.id IN (?)
                AND spree_taxons.lft < targets.lft
                AND spree_taxons.rgt > targets.rgt
            )", taxon_ids
          )
        )
        .pluck(:id, :taxonomy_id)

      # Separate originals from ancestors
      ancestor_ids = all_taxon_and_taxonomy_ids.map(&:first).uniq - taxon_ids
      taxonomy_ids = all_taxon_and_taxonomy_ids.map(&:last).uniq

      # Update ancestors only (originals already touched by Rails)
      Spree::Taxon.where(id: ancestor_ids).update_all(updated_at: Time.current) if ancestor_ids.any?

      # Update all taxonomies
      Spree::Taxonomy.where(id: taxonomy_ids).update_all(updated_at: Time.current)
    end
  end
end
