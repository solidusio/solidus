# frozen_string_literal: true

module SolidusFriendlyPromotions
  module AdjustmentDecorator
    def self.prepended(base)
      base.scope :friendly_promotion, -> { where(source_type: "SolidusFriendlyPromotions::Benefit") }
    end

    def friendly_promotion?
      source_type == "SolidusFriendlyPromotions::Benefit"
    end

    private

    def require_promotion_code?
      !friendly_promotion? && super
    end

    Spree::Adjustment.prepend self
  end
end
