# frozen_string_literal: true

module SolidusPromotions
  module OrderPatch
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

    # Used to keep track of any active promotion usage claims for the order.
    # Helps avoid large queries to the database for each promotion and code when
    # checking usage limits.
    attr_accessor :promotion_usage_claims

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

    def coupon_code=(code)
      @coupon_code = begin
        SolidusPromotions.config.coupon_code_normalizer_class.call(code)
      rescue
        nil
      end
    end

    Spree::Order.singleton_class.prepend self::ClassMethods
    Spree::Order.prepend self
  end
end
