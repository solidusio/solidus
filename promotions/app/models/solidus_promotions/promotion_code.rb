# frozen_string_literal: true

module SolidusPromotions
  class PromotionCode < Spree::Base
    belongs_to :promotion, -> { with_discarded }, inverse_of: :codes
    belongs_to :promotion_code_batch, inverse_of: :promotion_codes, optional: true

    has_many :order_promotions, class_name: "SolidusPromotions::OrderPromotion", dependent: :destroy

    before_validation :normalize_code

    validates :value, presence: true, uniqueness: { allow_blank: true, case_sensitive: true }
    validate :promotion_not_apply_automatically, on: :create

    self.allowed_ransackable_attributes = ["value"]

    # Whether the promotion code has exceeded its usage restrictions
    #
    # @param excluded_orders [Array<Spree::Order>] Orders to exclude from usage limit
    # @return true or false
    def usage_limit_exceeded?(excluded_orders: [])
      return unless usage_limit

      usage_count(excluded_orders: excluded_orders) >= usage_limit
    end

    # Number of times the code has been used overall
    #
    # @param excluded_orders [Array<Spree::Order>] Orders to exclude from usage count
    # @return [Integer] usage count
    def usage_count(excluded_orders: [])
      promotion
        .discounted_orders
        .complete
        .where.not(spree_orders: { state: :canceled })
        .joins(:solidus_order_promotions)
        .where(SolidusPromotions::OrderPromotion.table_name => { promotion_code_id: id })
        .where.not(id: excluded_orders.map(&:id))
        .count
    end

    def usage_limit
      promotion.per_code_usage_limit
    end

    def promotion_not_apply_automatically
      errors.add(:base, :disallowed_with_apply_automatically) if promotion.apply_automatically
    end

    private

    def normalize_code
      self.value = SolidusPromotions.config.coupon_code_normalizer_class.call(value)
    end
  end
end
