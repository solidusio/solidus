# frozen_string_literal: true

module SolidusPromotions
  module LineItemPatch
    def self.prepended(base)
      base.attr_accessor :quantity_setter
      base.belongs_to :managed_by_order_benefit, class_name: "SolidusPromotions::Benefit", optional: true
      base.validate :validate_managed_quantity_same, on: :update
      base.after_save :reset_quantity_setter
    end

    private

    def discounts_by_lanes(lanes)
      adjustments.select do |adjustment|
        !adjustment.marked_for_destruction? &&
          adjustment.source_type == "SolidusPromotions::Benefit" &&
          adjustment.source.promotion.lane.in?(lanes)
      end
    end

    def validate_managed_quantity_same
      if managed_by_order_benefit && quantity_changed? && quantity_setter != managed_by_order_benefit
        errors.add(:quantity, :cannot_be_changed_for_automated_items)
      end
    end

    def reset_quantity_setter
      @quantity_setter = nil
    end

    Spree::LineItem.prepend self
    Spree::LineItem.prepend SolidusPromotions::DiscountedAmount
    Spree::LineItem.prepend SolidusPromotions::DiscountableAmount
  end
end
