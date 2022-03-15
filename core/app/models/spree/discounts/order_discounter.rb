# frozen_string_literal: true

module Spree
  module Discounts
    class OrderDiscounter
      attr_reader :order

      def initialize(order)
        @order = order
      end

      def call
        discount_line_items
        discount_shipments
      end

      private

      def discount_line_items
        line_item_discounter = LineItemDiscounter.new(promotions: promotions)
        order.line_items.each { |line_item| line_item_discounter.call(line_item) }
      end

      def discount_shipments
        shipment_discounter = ShipmentDiscounter.new(promotions: promotions)
        order.shipments.each { |shipment| shipment_discounter.call(shipment) }
      end

      def promotions
        @_promotions ||= begin
          preloader = ActiveRecord::Associations::Preloader.new
          (connected_order_promotions | sale_promotions).select do |promotion|
            promotion.activatable?(order)
          end.map do |promotion|
            preloader.preload(promotion.rules.select { |r| r.type == "Spree::Promotion::Rules::Product" }, :products)
            preloader.preload(promotion.rules.select { |r| r.type == "Spree::Promotion::Rules::Store" }, :stores)
            preloader.preload(promotion.rules.select { |r| r.type == "Spree::Promotion::Rules::Taxon" }, :taxons)
            preloader.preload(promotion.rules.select { |r| r.type == "Spree::Promotion::Rules::User" }, :users)
            preloader.preload(promotion.actions.select { |a| a.respond_to?(:calculator) }, :calculator)
            promotion
          end
        end.select { |promotion| promotion.eligible_rules(order) }
      end

      def connected_order_promotions
        order.promotions.includes(promotion_includes).select(&:active?)
      end

      def sale_promotions
        Spree::Promotion.where(apply_automatically: true).active.includes(promotion_includes)
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
