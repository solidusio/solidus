# frozen_string_literal: true

module SolidusFriendlyPromotions
  class PromotionRulesTaxon < Spree::Base
    belongs_to :promotion_rule, class_name: "SolidusFriendlyPromotions::PromotionRule", optional: true
    belongs_to :taxon, class_name: "Spree::Taxon", optional: true
  end
end
