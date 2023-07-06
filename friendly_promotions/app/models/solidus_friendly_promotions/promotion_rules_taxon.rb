# frozen_string_literal: true

module SolidusFriendlyPromotions
  class PromotionRulesTaxon < Spree::Base
    belongs_to :promotion_rule
    belongs_to :taxon, class_name: "Spree::Taxon"
  end
end
