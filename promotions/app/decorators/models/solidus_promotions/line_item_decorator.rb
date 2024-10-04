# frozen_string_literal: true

module SolidusPromotions
  module LineItemDecorator
    def self.prepended(base)
      base.attr_accessor :quantity_setter
      base.belongs_to :managed_by_order_benefit, class_name: "SolidusPromotions::Benefit", optional: true
      base.validate :validate_managed_quantity_same, on: :update
      base.after_save :reset_quantity_setter
    end

    private

    def validate_managed_quantity_same
      if managed_by_order_benefit && quantity_changed? && quantity_setter != managed_by_order_benefit
        errors.add(:quantity, :cannot_be_changed_for_automated_items)
      end
    end

    def reset_quantity_setter
      @quantity_setter = nil
    end

    Spree::LineItem.prepend self
    Spree::LineItem.prepend SolidusPromotions::DiscountableAmount
  end
end
