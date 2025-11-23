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

      def taxons_ids_with_children=(args)
        @taxon_ids_with_children = args
      end

      private

      # Returns the cached list of taxon subtree id collections for the selected taxons.
      #
      # Executes a single SQL query using the nested set (lft/rgt) boundaries to
      # fetch each root taxon (one of this condition's taxons) together with all
      # of its descendants. The result is memoized for the lifetime of the
      # condition instance.
      #
      # Each inner array contains the IDs of a root taxon and all of its
      # descendants (including the root itself). The outer array is ordered by
      # the root taxon id.
      #
      # @return [Array<Array<Integer>>] array of arrays of taxon ids, one per root taxon
      # @example
      #   # For condition with taxons [10, 42]
      #   condition.condition_taxon_ids_with_children
      #   # => [[10, 11, 12], [42, 43]]
      def taxon_ids_with_children
        @taxon_ids_with_children ||= load_taxon_ids_with_children
      end

      def load_taxon_ids_with_children
        aggregation_function = if ActiveRecord::Base.connection.adapter_name.downcase.match?(/postgres/)
          "string_agg(child.id::text, ',')"
        else
          "group_concat(child.id, ',')"
        end

        sql = <<~SQL
          SELECT
            parent.id AS root_id,
            #{aggregation_function} AS descendant_ids
          FROM spree_taxons AS parent
          JOIN spree_taxons AS child
            ON child.lft BETWEEN parent.lft AND parent.rgt
          WHERE parent.id IN (#{taxon_ids.join(',')})
          GROUP BY parent.id
          ORDER BY parent.id
        SQL
        rows = ActiveRecord::Base.connection.exec_query(sql)
        rows.map { |r| r["descendant_ids"].split(",").map(&:to_i) }
      end
    end
  end
end
