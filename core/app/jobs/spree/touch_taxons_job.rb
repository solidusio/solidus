# frozen_string_literal: true

module Spree
  class TouchTaxonsJob < BaseJob

    def perform(taxon_ids)
      return if taxon_ids.blank?

      # Single query to get all target taxons ids and taxonomy ids plus 
      # those of their ancestors
      taxon_and_taxonomy_ids = Spree::Taxon
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

      target_taxon_ids = taxon_and_taxonomy_ids.map(&:first).uniq
      taxonomy_ids = taxon_and_taxonomy_ids.map(&:last).uniq

      Spree::Taxon.where(id: target_taxon_ids).update_all(updated_at: Time.current)
      Spree::Taxonomy.where(id: taxonomy_ids).update_all(updated_at: Time.current)
    end
  end
end
