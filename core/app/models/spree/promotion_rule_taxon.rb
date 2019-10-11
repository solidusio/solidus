# frozen_string_literal: true

module Solidus
  class PromotionRuleTaxon < Solidus::Base
    belongs_to :promotion_rule, optional: true
    belongs_to :taxon, optional: true
  end
end
