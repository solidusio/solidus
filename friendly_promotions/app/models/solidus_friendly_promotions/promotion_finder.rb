# frozen_string_literal: true

module SolidusFriendlyPromotions
  class PromotionFinder
    def self.by_code_or_id(coupon_code_or_id)
      SolidusFriendlyPromotions::Promotion.with_coupon_code(coupon_code_or_id.to_s) ||
        SolidusFriendlyPromotions::Promotion.find(coupon_code_or_id)
    end
  end
end
