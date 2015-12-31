module Solidus
  class PromotionRuleTaxon < Solidus::Base
    belongs_to :promotion_rule
    belongs_to :taxon
  end
end
