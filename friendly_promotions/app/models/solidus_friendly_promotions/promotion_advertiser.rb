# frozen_string_literal: true

module SolidusFriendlyPromotions
  class PromotionAdvertiser
    def self.for_product(product)
      promotion_ids = ProductsPromotionRule.joins(:promotion_rule).where(product: product).select(:promotion_id).distinct
      SolidusFriendlyPromotions::Promotion.advertised.where(id: promotion_ids).reject(&:inactive?)
    end
  end
end
