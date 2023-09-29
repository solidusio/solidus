# frozen_string_literal: true

module SolidusFriendlyPromotions
  class FriendlyPromotionDiscounter
    attr_reader :order, :promotions, :item_discounter

    def initialize(order)
      @order = Discountable::Order.new(order)
      @promotions = PromotionEligibility.new(promotable: order, possible_promotions: possible_promotions).call
      @item_discounter = ItemDiscounter.new(promotions: promotions)
    end

    def call
      return nil if order.shipped?

      adjust_line_items
      adjust_shipments
      adjust_shipping_rates
      order
    end

    private

    def adjust_line_items
      order.line_items.select do |line_item|
        line_item.variant.product.promotionable?
      end.flat_map { |line_item| item_discounter.call(line_item) }
    end

    def adjust_shipments
      order.shipments.flat_map { |shipment| item_discounter.call(shipment) }
    end

    def adjust_shipping_rates
      order.shipments.flat_map(&:shipping_rates).flat_map { |rate| item_discounter.call(rate) }
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
      order.friendly_promotions.active(reference_time).where(id: eligible_connected_promotion_ids).includes(promotion_includes)
    end

    def sale_promotions
      SolidusFriendlyPromotions::Promotion.where(apply_automatically: true).active(reference_time).includes(promotion_includes)
    end

    def reference_time
      order.completed_at || Time.current
    end

    def promotion_includes
      [
        :rules,
        :actions
      ]
    end
  end
end
