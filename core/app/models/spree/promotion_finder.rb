# frozen_string_literal: true

module Spree
  class PromotionFinder
    def self.by_code_or_id(coupon_code)
      Spree::Promotion.with_coupon_code(coupon_code.to_s) || Spree::Promotion.find(coupon_code)
    end
  end
end
