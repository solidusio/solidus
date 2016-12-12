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
        connected_promotions.each do |order_promotion|
          order_promotion.promotion.activate(
            order: order,
            promotion_code: order_promotion.promotion_code,
          )
        end

        not_connected_automatic_promotions.each do |promotion|
          promotion.activate(order: order)
        end
      end

      private

      def not_connected_automatic_promotions
        automatic_promotions - connected_promotions.map(&:promotion)
      end

      def automatic_promotions
        @automatic_promotions ||= active_free_shipping_promotions.
          where(apply_automatically: true).
          to_a.
          uniq
      end

      def connected_promotions
        @connected_promotions ||= order.order_promotions.
          joins(:promotion).
          includes(:promotion).
          merge(active_free_shipping_promotions).
          to_a.
          uniq
      end

      def active_free_shipping_promotions
        Spree::Promotion.all.
          active.
          joins(:promotion_actions).
          merge(
            Spree::PromotionAction.of_type(
              Spree::Promotion::Actions::FreeShipping
            )
          )
      end
    end
  end
end
