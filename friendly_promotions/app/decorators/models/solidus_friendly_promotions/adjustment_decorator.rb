# frozen_string_literal: true

module SolidusFriendlyPromotions
  module AdjustmentDecorator
    def self.prepended(base)
      base.scope :friendly_promotion, -> { where(source_type: "SolidusFriendlyPromotions::PromotionAction") }
      base.scope :promotion, -> { where(source_type: ["SolidusFriendlyPromotions::PromotionAction", "Spree::PromotionAction"]) }
    end

    def friendly_promotion?
      source_type == "SolidusFriendlyPromotions::PromotionAction"
    end

    def promotion?
      super || source_type == "SolidusFriendlyPromotions::PromotionAction"
    end

    private

    def require_promotion_code?
      !friendly_promotion? && super
    end

    Spree::Adjustment.prepend self
  end
end
