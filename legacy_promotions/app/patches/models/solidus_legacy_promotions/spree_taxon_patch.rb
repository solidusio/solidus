# frozen_string_literal: true

module SolidusLegacyPromotions
  module SpreeTaxonPatch
    def self.prepended(base)
      has_many :promotion_rule_taxons, dependent: :destroy
      has_many :promotion_rules, through: :promotion_rule_taxons

      base.after_discard do
        self.taxon_promotion_rules = []
      end
    end

    ::Spree::Taxon.prepend self
  end
end
