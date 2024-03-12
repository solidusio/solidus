# frozen_string_literal: true

module SolidusLegacyPromotions
  module OrderDecorator
    def self.prepended(base)
      base.state_machine do
        if states[:delivery]
          before_transition from: :delivery, do: :apply_shipping_promotions
        end
      end
    end

    def apply_shipping_promotions
      ::Spree::Config.promotions.shipping_promotion_handler_class.new(self).activate
      recalculate
    end

    def empty!
      order_promotions.destroy_all
      super
    end

    def can_add_coupon?
      ::Spree::Promotion.order_activatable?(self)
    end

    ::Spree::Order.prepend(self)
  end
end
