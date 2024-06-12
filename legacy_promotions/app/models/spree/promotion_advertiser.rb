# frozen_string_literal: true

module Spree
  class PromotionAdvertiser
    def self.for_product(product)
      promotion_ids = product.promotion_rules.map(&:promotion_id).uniq
      Spree::Promotion.advertised.where(id: promotion_ids).reject(&:inactive?)
    end
  end
end
