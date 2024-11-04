# frozen_string_literal: true

module SolidusPromotions
  module OrderDecorator
    module ClassMethods
      def allowed_ransackable_associations
        super + ["solidus_promotions", "solidus_order_promotions"]
      end
    end

    def self.prepended(base)
      base.has_many :solidus_order_promotions,
        class_name: "SolidusPromotions::OrderPromotion",
        dependent: :destroy,
        inverse_of: :order
      base.has_many :solidus_promotions, through: :solidus_order_promotions, source: :promotion
    end

    def discountable_item_total
      line_items.sum(&:discountable_amount)
    end

    def reset_current_discounts
      line_items.each(&:reset_current_discounts)
      shipments.each(&:reset_current_discounts)
    end

    # This helper method excludes line items that are managed by an order benefit for the benefit
    # of calculators and benefits that discount normal line items. Line items that are managed by an
    # order benefits handle their discounts themselves.
    def discountable_line_items
      line_items.reject(&:managed_by_order_benefit)
    end

    def free_from_order_benefit?(line_item, _options)
      !line_item.managed_by_order_benefit
    end

    Spree::Order.singleton_class.prepend self::ClassMethods
    Spree::Order.prepend self
  end
end
