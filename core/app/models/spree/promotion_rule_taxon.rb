module Spree
  class PromotionRuleTaxon < Spree::Base
    self.table_name = 'spree_taxons_promotion_rules'

    belongs_to :promotion_rule
    belongs_to :taxon
  end
end
