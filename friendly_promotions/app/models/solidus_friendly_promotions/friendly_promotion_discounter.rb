# frozen_string_literal: true

module SolidusFriendlyPromotions
  class FriendlyPromotionDiscounter
    attr_reader :order, :promotions

    def initialize(order)
      @order = order
      @promotions = PromotionEligibility.new(promotable: order, possible_promotions: possible_promotions).call
    end

    def call
      OrderDiscounts.new(
        order_id: order.id,
        line_item_discounts: adjust_line_items,
        shipment_discounts: adjust_shipments
      )
    end

    private

    def adjust_line_items
      line_item_adjuster = LineItemDiscounter.new(promotions: promotions)
      order.line_items.flat_map { |line_item| line_item_adjuster.call(line_item) }
    end

    def adjust_shipments
      shipment_adjuster = ShipmentDiscounter.new(promotions: promotions)
      order.shipments.flat_map { |shipment| shipment_adjuster.call(shipment) }
    end

    def possible_promotions
      promos = connected_order_promotions | sale_promotions
      promos.flat_map(&:actions).group_by(&:preload_relations).each do |preload_relations, actions|
        preload(records: actions, associations: preload_relations)
      end
      promos.flat_map(&:rules).group_by(&:preload_relations).each do |preload_relations, rules|
        preload(records: rules, associations: preload_relations)
      end
      promos.reject { |promotion| promotion.usage_limit_exceeded?(excluded_orders: [order]) }
    end

    def preload(records:, associations:)
      ActiveRecord::Associations::Preloader.new(records: records, associations: associations).call
    end

    def connected_order_promotions
      eligible_connected_promotion_ids = order.friendly_order_promotions.select do |order_promotion|
        order_promotion.promotion_code.nil? || !order_promotion.promotion_code.usage_limit_exceeded?(excluded_orders: [order])
      end.map(&:promotion_id)
      order.friendly_promotions.active.where(id: eligible_connected_promotion_ids).includes(promotion_includes)
    end

    def sale_promotions
      SolidusFriendlyPromotions::Promotion.where(apply_automatically: true).active.includes(promotion_includes)
    end

    def promotion_includes
      [
        :rules,
        :actions,
      ]
    end
  end
end
