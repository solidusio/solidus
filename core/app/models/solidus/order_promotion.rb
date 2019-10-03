# frozen_string_literal: true

module Solidus
  # Solidus::OrderPromotion represents the relationship between:
  #
  # 1. A promotion that a user attempted to apply to their order
  # 2. The specific code that they used
  class OrderPromotion < Solidus::Base
    self.table_name = 'spree_orders_promotions'

    belongs_to :order, class_name: 'Solidus::Order', optional: true
    belongs_to :promotion, class_name: 'Solidus::Promotion', optional: true
    belongs_to :promotion_code, class_name: 'Solidus::PromotionCode', optional: true

    validates :order, presence: true
    validates :promotion, presence: true
    validates :promotion_code, presence: true, if: :require_promotion_code?

    self.whitelisted_ransackable_associations = %w[promotion_code]

    private

    def require_promotion_code?
      promotion && promotion.codes.any?
    end
  end
end
