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

    def apply_shipping_promotions(_event = nil)
      ::Spree::Config.promotions.shipping_promotion_handler_class.new(self).activate
      recalculate
    end

    ::Spree::Order.prepend(self)
  end
end
