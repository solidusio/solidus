# frozen_string_literal: true

module SolidusFriendlyPromotions
  class PromotionRulesStore < Spree::Base
    belongs_to :promotion_rule, class_name: "SolidusFriendlyPromotions::PromotionRule", optional: true
    belongs_to :store, class_name: "Spree::Store", optional: true
  end
end
