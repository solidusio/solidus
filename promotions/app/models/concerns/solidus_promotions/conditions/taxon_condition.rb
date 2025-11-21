# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    module TaxonCondition
      def self.included(base)
        base.has_many :condition_taxons,
          class_name: "SolidusPromotions::ConditionTaxon",
          foreign_key: :condition_id,
          dependent: :destroy,
          inverse_of: :condition
        base.has_many :taxons, through: :condition_taxons, class_name: "Spree::Taxon"
      end

      def preload_relations
        [:taxons]
      end

      def taxon_ids_string
        taxon_ids.join(",")
      end

      def taxon_ids_string=(taxon_ids)
        taxon_ids = taxon_ids.to_s.split(",").map(&:strip)
        self.taxons = Spree::Taxon.find(taxon_ids)
      end

      private

      # ids of taxons conditions and taxons conditions children
      def taxon_ids_with_children
        @taxon_ids_with_children ||= taxons.map { |taxon| taxon.self_and_descendants.ids }.uniq
      end
    end
  end
end
