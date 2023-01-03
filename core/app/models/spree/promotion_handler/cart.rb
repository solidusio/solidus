# frozen_string_literal: true

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
        promotions.each do |promotion|
          if (line_item && promotion.eligible?(line_item, promotion_code: promotion_code(promotion))) || promotion.eligible?(order, promotion_code: promotion_code(promotion))
            promotion.activate(line_item: line_item, order: order, promotion_code: promotion_code(promotion))
          end
        end
      end

      private

      def promotions
        promos = connected_order_promotions | sale_promotions
        promos.flat_map(&:promotion_actions).group_by(&:preload_relations).each do |preload_relations, actions|
          preload(records: actions, associations: preload_relations)
        end
        promos.flat_map(&:promotion_rules).group_by(&:preload_relations).each do |preload_relations, rules|
          preload(records: rules, associations: preload_relations)
        end
        promos
      end

      def preload(records:, associations:)
        if Rails::VERSION::MAJOR >= 7
          ActiveRecord::Associations::Preloader.new(records: records, associations: associations).call
        else
          ActiveRecord::Associations::Preloader.new.preload(records, associations)
        end
      end

      def connected_order_promotions
        order.promotions.active.includes(promotion_includes)
      end

      def sale_promotions
        Spree::Promotion.where(apply_automatically: true).active.includes(promotion_includes)
      end

      def promotion_code(promotion)
        order_promotion = order.order_promotions.detect { |op| op.promotion_id == promotion.id }
        order_promotion.present? ? order_promotion.promotion_code : nil
      end

      def promotion_includes
        [
          :promotion_rules,
          :promotion_actions,
        ]
      end
    end
  end
end

