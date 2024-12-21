# frozen_string_literal: true

module SolidusLegacyPromotions
  module SpreeOrderPatch
    module ClassMethods
      def allowed_ransackable_associations
        super + ["promotions", "order_promotions"]
      end
    end

    def self.prepended(base)
      base.has_many :order_promotions, class_name: 'Spree::OrderPromotion', dependent: :destroy
      base.has_many :promotions, through: :order_promotions
    end

    def apply_shipping_promotions(_event = nil)
      Spree::Config.promotions.shipping_promotion_handler_class.new(self).activate
      recalculate
    end

    def shipping_discount
      shipment_adjustments.credit.eligible.sum(:amount) * - 1
    end

    Spree::Order.prepend(self)
    Spree::Order.singleton_class.prepend self::ClassMethods
  end
end
