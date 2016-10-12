module Spree
  module PromotionHandler
    # Used for activating promotions with shipping rules
    class FreeShipping
      attr_reader :order
      attr_accessor :error, :success

      def initialize(order)
        @order = order
      end

      def activate
        promotions.each do |promotion|
          if order_promotion = existing_order_promotion(promotion)
            promotion.activate(
              order: order,
              promotion_code: order_promotion.promotion_code,
            )
          elsif promotion.apply_automatically?
            promotion.activate(order: order)
          end
        end
      end

      private

      def promotions
        Spree::Promotion.
          active.
          joins(:promotion_actions).
          merge(
            Spree::PromotionAction.of_type(
              Spree::Promotion::Actions::FreeShipping
            )
          ).
          distinct
      end

      def existing_order_promotion(promotion)
        @lookup ||= order.order_promotions.map do |order_promotion|
          [order_promotion.promotion_id, order_promotion]
        end.to_h

        @lookup[promotion.id]
      end
    end
  end
end
