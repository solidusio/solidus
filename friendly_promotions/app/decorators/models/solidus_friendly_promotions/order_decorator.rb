# frozen_string_literal: true

module SolidusFriendlyPromotions
  module OrderDecorator
    def self.prepended(base)
      base.has_many :friendly_order_promotions,
        class_name: "SolidusFriendlyPromotions::OrderPromotion",
        dependent: :destroy,
        inverse_of: :order
      base.has_many :friendly_promotions, through: :friendly_order_promotions, source: :promotion
    end

    def ensure_promotions_eligible
      Spree::Config.promotion_adjuster_class.new(self).call
      if promo_total_changed?
        restart_checkout_flow
        recalculate
        errors.add(:base, I18n.t("solidus_friendly_promotions.promotion_total_changed_before_complete"))
      end
      errors.empty?
    end

    def discountable_item_total
      line_items.sum(&:discountable_amount)
    end

    def reset_current_discounts
      line_items.each(&:reset_current_discounts)
      shipments.each(&:reset_current_discounts)
    end

    Spree::Order.prepend self
  end
end
