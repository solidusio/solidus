# frozen_string_literal: true

module Spree
  class PromotionRuleTaxon < Spree::Base
    belongs_to :promotion_rule
    belongs_to :taxon
  end
end
