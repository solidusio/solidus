# frozen_string_literal: true

module Spree
  class PromotionRuleTaxon < Spree::Base
    belongs_to :promotion_rule, optional: true
    belongs_to :taxon, optional: true
  end
end
