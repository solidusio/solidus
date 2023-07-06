# frozen_string_literal: true

module SolidusFriendlyPromotions::OrderDecorator
    def self.prepended(base)
      base.has_many :friendly_order_promotions, class_name: "SolidusFriendlyPromotions::OrderPromotion", inverse_of: :order
      base.has_many :friendly_promotions, through: :friendly_order_promotions, source: :promotion
    end
    Spree::Order.prepend self
  end
