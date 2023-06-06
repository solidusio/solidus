# frozen_string_literal: true

module SolidusFriendlyPromotions
  class OrderPromotionAdjuster
    attr_reader :order, :promotions

    def initialize(order)
      @order = order
      @promotions = PromotionEligibility.new(promotable: order, possible_promotions: possible_promotions).call
    end

    def call
      adjust_line_items
      adjust_shipments
      order.promo_total = (order.line_items + order.shipments).sum { |item| item.promo_total }
      order
    end

    private

    def adjust_line_items
      line_item_adjuster = LineItemAdjuster.new(promotions: promotions)
      order.line_items.each { |line_item| line_item_adjuster.call(line_item) }
    end

    def adjust_shipments
      shipment_adjuster = ShipmentAdjuster.new(promotions: promotions)
      order.shipments.each { |shipment| shipment_adjuster.call(shipment) }
    end

    def possible_promotions
      promos = connected_order_promotions | sale_promotions
      promos.flat_map(&:promotion_actions).group_by(&:preload_relations).each do |preload_relations, actions|
        preload(records: actions, associations: preload_relations)
      end
      promos.flat_map(&:promotion_rules).group_by(&:preload_relations).each do |preload_relations, rules|
        preload(records: rules, associations: preload_relations)
      end
      promos.reject { |promotion| promotion.usage_limit_exceeded?(excluded_orders: [order]) }
    end

    def preload(records:, associations:)
      ActiveRecord::Associations::Preloader.new(records: records, associations: associations).call
    end

    def connected_order_promotions
      order.promotions.active.includes(promotion_includes)
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
