# frozen_string_literal: true

module SolidusFriendlyPromotions
  class MigrateOrderPromotions
    class << self
      def up
        Spree::OrderPromotion.all.each do |order_promotion|
          friendly_promotion = SolidusFriendlyPromotions::Promotion.find_by!(original_promotion_id: order_promotion.promotion.id)
          if order_promotion.promotion_code
            friendly_promotion_code = friendly_promotion.codes.find_by(value: order_promotion.promotion_code.value)
          end
          SolidusFriendlyPromotions::OrderPromotion.find_or_create_by!(order: order_promotion.order,
            promotion: friendly_promotion,
            promotion_code: friendly_promotion_code)
          order_promotion.destroy!
        end
      end

      def down
        SolidusFriendlyPromotions::OrderPromotion.all.each do |friendly_order_promotion|
          spree_promotion = friendly_order_promotion.promotion.original_promotion
          if friendly_order_promotion.promotion_code
            spree_promotion_code = spree_promotion.promotion_codes.find_by(value: friendly_order_promotion.promotion_code.value)
          end
          Spree::OrderPromotion.find_or_create_by!(order: friendly_order_promotion.order,
            promotion: spree_promotion,
            promotion_code: spree_promotion_code)
          friendly_order_promotion.destroy!
        end
      end
    end
  end
end
