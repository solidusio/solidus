# frozen_string_literal: true

module SolidusPromotions
  class PromotionFinder
    def self.by_code_or_id(coupon_code_or_id)
      SolidusPromotions::Promotion.with_coupon_code(coupon_code_or_id.to_s) ||
        SolidusPromotions::Promotion.find(coupon_code_or_id)
    end
  end
end
