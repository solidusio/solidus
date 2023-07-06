# frozen_string_literal: true

module SolidusFriendlyPromotions
  module AdjustmentDecorator
    def self.prepended(base)
      base.scope :friendly_promotion, -> { where(source_type: "SolidusFriendlyPromotions::PromotionAction") }
    end

    def friendly_promotion?
      source_type == "SolidusFriendlyPromotions::PromotionAction"
    end
    Spree::Adjustment.prepend self
  end
end
