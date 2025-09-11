# frozen_string_literal: true

module SolidusPromotions
  module MigrationSupport
    class OrderPromotionSyncer
      attr_reader :order

      def initialize(order:)
        @order = order
      end

      def call
        sync_spree_order_promotions_to_solidus_order_promotions
        sync_solidus_order_promotions_to_spree_order_promotions
      end

      private

      def sync_spree_order_promotions_to_solidus_order_promotions
        order.order_promotions.each do |spree_order_promotion|
          solidus_promotion = SolidusPromotions::Promotion.find_by(
            original_promotion_id: spree_order_promotion.promotion.id
          )
          next unless solidus_promotion

          if spree_order_promotion.promotion_code
            solidus_promotion_code = solidus_promotion.codes.find_by(
              value: spree_order_promotion.promotion_code.value
            )
          end
          order.solidus_order_promotions.find_or_create_by!(
            promotion: solidus_promotion,
            promotion_code: solidus_promotion_code
          )
        end
      end

      def sync_solidus_order_promotions_to_spree_order_promotions
        order.solidus_order_promotions.each do |solidus_order_promotion|
          spree_promotion = solidus_order_promotion.promotion.original_promotion
          next unless spree_promotion

          if solidus_order_promotion.promotion_code
            spree_promotion_code = spree_promotion.promotion_codes.find_by(
              value: solidus_order_promotion.promotion_code.value
            )
          end
          order.order_promotions.find_or_create_by!(
            promotion: spree_promotion,
            promotion_code: spree_promotion_code
          )
        end
      end
    end
  end
end
