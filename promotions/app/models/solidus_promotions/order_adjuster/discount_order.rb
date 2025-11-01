# frozen_string_literal: true

module SolidusPromotions
  class OrderAdjuster
    class DiscountOrder
      attr_reader :order, :promotions, :dry_run

      def initialize(order, promotions, dry_run: false)
        @order = order
        @promotions = promotions
        @dry_run = dry_run
      end

      def call
        return order if order.shipped?

        SolidusPromotions::Promotion.ordered_lanes.each do |lane|
          lane_promotions = promotions.select { |promotion| promotion.lane == lane }
          lane_benefits = eligible_benefits_for_promotable(lane_promotions.flat_map(&:benefits), order)
          perform_order_benefits(lane_benefits, lane) unless dry_run
          line_item_discounts = adjust_line_items(lane_benefits)
          shipment_discounts = adjust_shipments(lane_benefits)
          shipping_rate_discounts = adjust_shipping_rates(lane_benefits)
          (line_item_discounts + shipment_discounts + shipping_rate_discounts).each do |item, chosen_discounts|
            item.current_discounts.concat(chosen_discounts)
          end
        end

        order
      end

      private

      def perform_order_benefits(lane_benefits, lane)
        lane_benefits.select { |benefit| benefit.level == :order }.each do |benefit|
          benefit.perform(order)
        end

        automated_line_items = order.line_items.select(&:managed_by_order_benefit)
        return if automated_line_items.empty?

        ineligible_line_items = automated_line_items.select do |line_item|
          line_item.managed_by_order_benefit.promotion.lane == lane && !line_item.managed_by_order_benefit.in?(lane_benefits)
        end

        ineligible_line_items.each do |line_item|
          line_item.managed_by_order_benefit.remove_from(order)
        end
      end

      def adjust_line_items(benefits)
        order.discountable_line_items.select do |line_item|
          line_item.variant.product.promotionable?
        end.map do |line_item|
          discounts = generate_discounts(benefits, line_item)
          chosen_item_discounts = SolidusPromotions.config.discount_chooser_class.new(discounts).call
          [line_item, chosen_item_discounts]
        end
      end

      def adjust_shipments(benefits)
        order.shipments.map do |shipment|
          discounts = generate_discounts(benefits, shipment)
          chosen_item_discounts = SolidusPromotions.config.discount_chooser_class.new(discounts).call
          [shipment, chosen_item_discounts]
        end
      end

      def adjust_shipping_rates(benefits)
        order.shipments.flat_map(&:shipping_rates).select(&:cost).map do |rate|
          discounts = generate_discounts(benefits, rate)
          chosen_item_discounts = SolidusPromotions.config.discount_chooser_class.new(discounts).call
          [rate, chosen_item_discounts]
        end
      end

      def eligible_benefits_for_promotable(possible_benefits, promotable)
        possible_benefits.select do |candidate|
          candidate.eligible_by_applicable_conditions?(promotable, dry_run: dry_run)
        end
      end

      def generate_discounts(possible_benefits, item)
        eligible_benefits = eligible_benefits_for_promotable(possible_benefits, item)
        eligible_benefits.select do |benefit|
          benefit.can_discount?(item)
        end.map do |benefit|
          benefit.discount(item)
        end.compact
      end
    end
  end
end
