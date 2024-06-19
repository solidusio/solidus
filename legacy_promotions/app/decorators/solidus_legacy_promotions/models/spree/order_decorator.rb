# frozen_string_literal: true

module SolidusLegacyPromotions
  module OrderDecorator
    def apply_shipping_promotions(_event = nil)
      ::Spree::Config.promotions.shipping_promotion_handler_class.new(self).activate
      recalculate
    end

    ::Spree::Order.prepend(self)
  end
end
