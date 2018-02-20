# frozen_string_literal: true

module Spree
  module PromotionHandler
    # Used for activating promotions with shipping rules
    class Shipping
      attr_reader :order
      attr_accessor :error, :success

      def initialize(order)
        @order = order
      end

      def activate
        connected_promotions.each do |order_promotion|
          if order_promotion.promotion.eligible?(order)
            order_promotion.promotion.activate(
              order: order,
              promotion_code: order_promotion.promotion_code,
            )
          end
        end

        not_connected_automatic_promotions.each do |promotion|
          if promotion.eligible?(order)
            promotion.activate(order: order)
          end
        end
      end

      private

      def not_connected_automatic_promotions
        automatic_promotions - connected_promotions.map(&:promotion)
      end

      def automatic_promotions
        @automatic_promotions ||= active_shipping_promotions.
          where(apply_automatically: true).
          to_a.
          uniq
      end

      def connected_promotions
        @connected_promotions ||= order.order_promotions.
          joins(:promotion).
          includes(:promotion).
          merge(active_shipping_promotions).
          to_a.
          uniq
      end

      def active_shipping_promotions
        Spree::Promotion.all.
          active.
          joins(:promotion_actions).
          merge(Spree::PromotionAction.shipping)
      end
    end
  end
end
