# frozen_string_literal: true

module SolidusFriendlyPromotions
  class FriendlyPromotionAdjuster
    class DiscountOrder
      attr_reader :order, :promotions, :dry_run

      def initialize(order, promotions, dry_run: false)
        @order = order
        @promotions = promotions
        @dry_run = dry_run
      end

      def call
        return order if order.shipped?

        SolidusFriendlyPromotions::Promotion.ordered_lanes.each do |lane, _index|
          lane_promotions = eligible_promotions_for_promotable(promotions.select { |promotion| promotion.lane == lane }, order)
          perform_order_actions(lane_promotions)
          line_item_discounts = adjust_line_items(lane_promotions)
          shipment_discounts = adjust_shipments(lane_promotions)
          shipping_rate_discounts = adjust_shipping_rates(lane_promotions)
          (line_item_discounts + shipment_discounts + shipping_rate_discounts).each do |item, chosen_discounts|
            item.current_discounts.concat(chosen_discounts)
          end
        end

        order
      end

      private

      def perform_order_actions(lane_promotions)
        lane_promotions.each do |promotion|
          promotion.actions.select { |action| action.level == :order }.each { |action| action.perform(order) }
        end
      end

      def adjust_line_items(promotions)
        order.line_items.select do |line_item|
          line_item.variant.product.promotionable? && !line_item.managed_by_automation
        end.map do |line_item|
          discounts = generate_discounts(promotions, line_item)
          chosen_item_discounts = SolidusFriendlyPromotions.config.discount_chooser_class.new(discounts).call
          [line_item, chosen_item_discounts]
        end
      end

      def adjust_shipments(promotions)
        order.shipments.map do |shipment|
          discounts = generate_discounts(promotions, shipment)
          chosen_item_discounts = SolidusFriendlyPromotions.config.discount_chooser_class.new(discounts).call
          [shipment, chosen_item_discounts]
        end
      end

      def adjust_shipping_rates(promotions)
        order.shipments.flat_map(&:shipping_rates).select(&:cost).map do |rate|
          discounts = generate_discounts(promotions, rate)
          chosen_item_discounts = SolidusFriendlyPromotions.config.discount_chooser_class.new(discounts).call
          [rate, chosen_item_discounts]
        end
      end

      def eligible_promotions_for_promotable(possible_promotions, promotable)
        possible_promotions.select do |candidate|
          candidate.eligible_by_applicable_rules?(promotable, dry_run: dry_run)
        end
      end

      def generate_discounts(possible_promotions, item)
        eligible_promotions = eligible_promotions_for_promotable(possible_promotions, item)
        eligible_promotions.flat_map do |promotion|
          promotion.actions.select do |action|
            action.can_discount?(item)
          end.map do |action|
            action.discount(item)
          end.compact
        end
      end
    end
  end
end
