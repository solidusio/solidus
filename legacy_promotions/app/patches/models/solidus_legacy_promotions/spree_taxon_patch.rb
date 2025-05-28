# frozen_string_literal: true

module SolidusLegacyPromotions
  module SpreeTaxonPatch
    def self.prepended(base)
      base.has_many :promotion_rule_taxons, dependent: :destroy
      base.has_many :promotion_rules, through: :promotion_rule_taxons
    end

    ::Spree::Taxon.prepend self
  end
end
