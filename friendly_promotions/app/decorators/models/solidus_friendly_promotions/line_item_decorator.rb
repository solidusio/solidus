# frozen_string_literal: true

module SolidusFriendlyPromotions
  module LineItemDecorator
    def self.prepended(base)
      base.belongs_to :managed_by_order_action, class_name: "SolidusFriendlyPromotions::PromotionAction", optional: true
    end
    Spree::LineItem.prepend self
    Spree::LineItem.prepend SolidusFriendlyPromotions::DiscountableAmount
  end
end
