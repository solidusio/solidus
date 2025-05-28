# frozen_string_literal: true

module SolidusPromotions
  # SolidusPromotions::OrderPromotion represents the relationship between:
  #
  # 1. A promotion that a user attempted to apply to their order
  # 2. The specific code that they used
  class OrderPromotion < Spree::Base
    belongs_to :order, class_name: "Spree::Order"
    belongs_to :promotion, -> { with_discarded }, class_name: "SolidusPromotions::Promotion", inverse_of: :order_promotions
    belongs_to :promotion_code, class_name: "SolidusPromotions::PromotionCode", optional: true

    validates :promotion_code, presence: true, if: :require_promotion_code?

    self.allowed_ransackable_associations = %w[promotion_code]

    private

    def require_promotion_code?
      promotion && !promotion.apply_automatically && promotion.codes.any?
    end
  end
end
