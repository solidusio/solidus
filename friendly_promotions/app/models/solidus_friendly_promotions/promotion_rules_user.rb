# frozen_string_literal: true

module SolidusFriendlyPromotions
  class PromotionRulesUser < Spree::Base
    belongs_to :promotion_rule, class_name: "SolidusFriendlyPromotions::PromotionRule", optional: true
    belongs_to :user, class_name: Spree::UserClassHandle.new, optional: true
  end
end
