class Spree::PromotionCode < ActiveRecord::Base
  belongs_to :promotion, inverse_of: :codes
  has_many :adjustments

  validates :value, presence: true, uniqueness: true
  validates :promotion, presence: true

  before_save :downcase_value

  # Whether the promotion code has exceeded its usage restrictions
  #
  # @param promotable object (e.g. order/line item/shipment) No longer used.
  # @return true or false
  def usage_limit_exceeded?(promotable = nil)
    if usage_limit
      usage_count >= usage_limit
    end
  end

  # Number of times the code has been used overall
  #
  # @return [Integer] usage count
  def usage_count
    adjustments.eligible.
      joins(:order).
      merge(Spree::Order.complete).
      distinct.
      count(:order_id)
  end

  def usage_limit
    promotion.per_code_usage_limit
  end

  private

  def downcase_value
    self.value = value.downcase
  end

  def adjustment_promotion_scope(adjustment_scope)
  end
end
