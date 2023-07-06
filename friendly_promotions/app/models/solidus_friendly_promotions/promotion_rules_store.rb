# frozen_string_literal: true

module SolidusFriendlyPromotions
  class PromotionRulesStore < Spree::Base
    belongs_to :promotion_rule
    belongs_to :store, class_name: "Spree::Store"
  end
end
