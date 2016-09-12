module Spree
  module PromotionHandler
    # Decides which promotion should be activated given the current order context
    #
    # By activated it doesn't necessarily mean that the order will have a
    # discount for every activated promotion. It means that the discount will be
    # created and might eventually become eligible. The intention here is to
    # reduce overhead. e.g. a promotion that requires item A to be eligible
    # shouldn't be eligible unless item A is added to the order.
    #
    # It can be used as a wrapper for custom handlers as well. Different
    # applications might have completely different requirements to make
    # the promotions system accurate and performant. Here they can plug custom
    # handler to activate promos as they wish once an item is added to cart
    class Cart
      attr_reader :line_item, :order
      attr_accessor :error, :success

      def initialize(order, line_item = nil)
        @order, @line_item = order, line_item
      end

      def activate
        connected_order_promotions.each do |promotion|
          activate_promotion(promotion)
        end

        sale_promotions.each do |promotion|
          if apply_sale_promotion?(promotion)
            activate_promotion(promotion)
          end
        end
      end

      private

      def activate_promotion(promotion)
        if line_item_eligible?(promotion) || order_eligible?(promotion)
          promotion.activate(line_item: line_item, order: order, promotion_code: promotion_code(promotion))
        end
      end

      def apply_sale_promotion?(promotion)
        Spree::Config.automatic_promotion_decision_class.
          new(order: order, promotion: promotion).
          attempt_to_apply?
      end

      def line_item_eligible?(promotion)
        line_item &&
          promotion.eligible?(
            line_item,
            promotion_code: promotion_code(promotion),
          )
      end

      def order_eligible?(promotion)
        promotion.eligible?(
          order,
          promotion_code: promotion_code(promotion),
        )
      end

      def connected_order_promotions
        @connected_order_promotions ||= Promotion.
          active.
          includes(:promotion_rules).
          joins(:order_promotions).
          where(spree_orders_promotions: { order_id: order.id }).
          readonly(false).
          to_a
      end

      def sale_promotions
        @sale_promotions ||= Promotion.
          where(apply_automatically: true).
          active.
          includes(:promotion_rules).
          to_a
      end

      def promotion_code(promotion)
        order_promotion = Spree::OrderPromotion.where(order: order, promotion: promotion).first
        order_promotion.present? ? order_promotion.promotion_code : nil
      end
    end
  end
end
