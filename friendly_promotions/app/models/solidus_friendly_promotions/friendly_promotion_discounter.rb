# frozen_string_literal: true

module SolidusFriendlyPromotions
  class FriendlyPromotionDiscounter
    attr_reader :order, :promotions

    def initialize(order)
      @order = Discountable::Order.new(order)
      @promotions = PromotionEligibility.new(promotable: order, possible_promotions: possible_promotions).call
    end

    def call
      return nil if order.shipped?

      SolidusFriendlyPromotions::Promotion.ordered_lanes.each do |lane, _index|
        lane_promotions = promotions.select { |promotion| promotion.lane == lane }
        item_discounter = ItemDiscounter.new(promotions: lane_promotions)
        line_item_discounts = adjust_line_items(item_discounter)
        shipment_discounts = adjust_shipments(item_discounter)
        shipping_rate_discounts = adjust_shipping_rates(item_discounter)
        (line_item_discounts + shipment_discounts + shipping_rate_discounts).each do |item, chosen_discounts|
          item.discounts.concat(chosen_discounts)
        end
      end

      order
    end

    private

    def adjust_line_items(item_discounter)
      order.line_items.select do |line_item|
        line_item.variant.product.promotionable?
      end.map do |line_item|
        discounts = item_discounter.call(line_item)
        chosen_item_discounts = SolidusFriendlyPromotions.config.discount_chooser_class.new(line_item).call(discounts)
        [line_item, chosen_item_discounts]
      end
    end

    def adjust_shipments(item_discounter)
      order.shipments.map do |shipment|
        discounts = item_discounter.call(shipment)
        chosen_item_discounts = SolidusFriendlyPromotions.config.discount_chooser_class.new(shipment).call(discounts)
        [shipment, chosen_item_discounts]
      end
    end

    def adjust_shipping_rates(item_discounter)
      order.shipments.flat_map(&:shipping_rates).map do |rate|
        discounts = item_discounter.call(rate)
        chosen_item_discounts = SolidusFriendlyPromotions.config.discount_chooser_class.new(rate).call(discounts)
        [rate, chosen_item_discounts]
      end
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
