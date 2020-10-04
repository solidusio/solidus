# frozen_string_literal: true

class Spree::PromotionCode < Spree::Base
  belongs_to :promotion, inverse_of: :codes, optional: true
  belongs_to :promotion_code_batch, class_name: "Spree::PromotionCodeBatch", optional: true
  has_many :adjustments

  validates :value, presence: true, uniqueness: { allow_blank: true, case_sensitive: true }
  validates :promotion, presence: true
  validate :promotion_not_apply_automatically, on: :create

  before_save :normalize_code

  self.whitelisted_ransackable_attributes = ['value']

  # Whether the promotion code has exceeded its usage restrictions
  #
  # @param excluded_orders [Array<Spree::Order>] Orders to exclude from usage limit
  # @return true or false
  def usage_limit_exceeded?(excluded_orders: [])
    if usage_limit
      usage_count(excluded_orders: excluded_orders) >= usage_limit
    end
  end

  # Number of times the code has been used overall
  #
  # @param excluded_orders [Array<Spree::Order>] Orders to exclude from usage count
  # @return [Integer] usage count
  def usage_count(excluded_orders: [])
    adjustments.
    eligible.
    in_completed_orders(excluded_orders: excluded_orders).
    count(:order_id)
  end

  def usage_limit
    promotion.per_code_usage_limit
  end

  def promotion_not_apply_automatically
    errors.add(:base, :disallowed_with_apply_automatically) if promotion.apply_automatically
  end

  private

  def normalize_code
    self.value = value.downcase.strip
  end
end
