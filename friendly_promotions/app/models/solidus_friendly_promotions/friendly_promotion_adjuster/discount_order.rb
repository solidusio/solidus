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
          lane_promotions = promotions.select { |promotion| promotion.lane == lane }
          lane_actions = eligible_actions_for_promotable(lane_promotions.flat_map(&:actions), order)
          perform_order_actions(lane_actions, lane) unless dry_run
          line_item_discounts = adjust_line_items(lane_actions)
          shipment_discounts = adjust_shipments(lane_actions)
          shipping_rate_discounts = adjust_shipping_rates(lane_actions)
          (line_item_discounts + shipment_discounts + shipping_rate_discounts).each do |item, chosen_discounts|
            item.current_discounts.concat(chosen_discounts)
          end
        end

        order
      end

      private

      def perform_order_actions(lane_actions, lane)
        lane_actions.select { |action| action.level == :order }.each do |action|
          action.perform(order)
        end

        automated_line_items = order.line_items.select(&:managed_by_order_action)
        return if automated_line_items.empty?

        ineligible_line_items = automated_line_items.select do |line_item|
          line_item.managed_by_order_action.promotion.lane == lane && !line_item.managed_by_order_action.in?(lane_actions)
        end

        ineligible_line_items.each do |line_item|
          line_item.managed_by_order_action.remove_from(order)
        end
      end

      def adjust_line_items(actions)
        order.discountable_line_items.select do |line_item|
          line_item.variant.product.promotionable?
        end.map do |line_item|
          discounts = generate_discounts(actions, line_item)
          chosen_item_discounts = SolidusFriendlyPromotions.config.discount_chooser_class.new(discounts).call
          [line_item, chosen_item_discounts]
        end
      end

      def adjust_shipments(actions)
        order.shipments.map do |shipment|
          discounts = generate_discounts(actions, shipment)
          chosen_item_discounts = SolidusFriendlyPromotions.config.discount_chooser_class.new(discounts).call
          [shipment, chosen_item_discounts]
        end
      end

      def adjust_shipping_rates(actions)
        order.shipments.flat_map(&:shipping_rates).select(&:cost).map do |rate|
          discounts = generate_discounts(actions, rate)
          chosen_item_discounts = SolidusFriendlyPromotions.config.discount_chooser_class.new(discounts).call
          [rate, chosen_item_discounts]
        end
      end

      def eligible_actions_for_promotable(possible_actions, promotable)
        possible_actions.select do |candidate|
          candidate.eligible_by_applicable_conditions?(promotable, dry_run: dry_run)
        end
      end

      def generate_discounts(possible_actions, item)
        eligible_actions = eligible_actions_for_promotable(possible_actions, item)
        eligible_actions.select do |action|
          action.can_discount?(item)
        end.map do |action|
          action.discount(item)
        end.compact
      end
    end
  end
end
