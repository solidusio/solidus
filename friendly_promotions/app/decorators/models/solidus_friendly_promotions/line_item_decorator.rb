# frozen_string_literal: true

module SolidusFriendlyPromotions
  module LineItemDecorator
    def self.prepended(base)
      base.belongs_to :managed_by_order_action, class_name: "SolidusFriendlyPromotions::PromotionAction", optional: true
      base.validate :validate_managed_quantity_same, on: :update
    end

    private

    def validate_managed_quantity_same
      if managed_by_order_action && quantity_changed?
        errors.add(:quantity, :cannot_be_changed_for_automated_items)
      end
    end

    Spree::LineItem.prepend self
    Spree::LineItem.prepend SolidusFriendlyPromotions::DiscountableAmount
  end
end
