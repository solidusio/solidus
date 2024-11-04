# frozen_string_literal: true

module SolidusPromotions
  class PromotionAdvertiser
    def self.for_product(product)
      promotion_ids = ConditionProduct.joins(condition: :benefit).where(product: product).select(:promotion_id).distinct
      SolidusPromotions::Promotion.advertised.where(id: promotion_ids).reject(&:inactive?)
    end
  end
end
