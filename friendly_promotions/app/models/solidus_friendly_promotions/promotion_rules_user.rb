# frozen_string_literal: true

module SolidusFriendlyPromotions
  class PromotionRulesUser < Spree::Base
    belongs_to :promotion_rule
    belongs_to :user, class_name: Spree::UserClassHandle.new
  end
end
