# frozen_string_literal: true

module SolidusFriendlyPromotions
  module MigrationSupport
    class OrderPromotionSyncer
      attr_reader :order

      def initialize(order:)
        @order = order
      end

      def call
        order.order_promotions.each do |spree_order_promotion|
          friendly_promotion = SolidusFriendlyPromotions::Promotion.find_by(
            original_promotion_id: spree_order_promotion.promotion.id
          )
          next unless friendly_promotion
          if spree_order_promotion.promotion_code
            friendly_promotion_code = friendly_promotion.codes.find_by(
              value: spree_order_promotion.promotion_code.value
            )
          end
          order.friendly_order_promotions.find_or_create_by!(
            promotion: friendly_promotion,
            promotion_code: friendly_promotion_code
          )
        end
      end
    end
  end
end
