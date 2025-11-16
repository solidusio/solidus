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
          SolidusPromotions::PromotionLane.set(current_lane: lane) do
            lane_promotions = promotions.select { |promotion| promotion.lane == lane }
            lane_benefits = eligible_benefits_for_promotable(lane_promotions.flat_map(&:benefits), order)
            perform_order_benefits(lane_benefits, lane) unless dry_run
            adjust_line_items(lane_benefits)
            adjust_shipments(lane_benefits)
            adjust_shipping_rates(lane_benefits)
          end
        end

        order.line_items.each do |line_item|
          line_item.adjustments.select { _1.amount.zero? }.each(&:mark_for_destruction)
          line_item.promo_total = line_item.adjustments.reject(&:marked_for_destruction?).sum(&:amount)
          line_item.adjustment_total = line_item.promo_total
        end

        order.shipments.each do |shipment|
          shipment.adjustments.select { _1.amount.zero? }.each(&:mark_for_destruction)
          shipment.promo_total = shipment.adjustments.reject(&:marked_for_destruction?).sum(&:amount)
          shipment.shipping_rates.each do |shipping_rate|
            shipping_rate.discounts.select { _1.amount.zero? }.each(&:mark_for_destruction)
          end
          shipment.adjustment_total = shipment.promo_total
        end

        line_items = order.line_items.reject(&:marked_for_destruction?)
        order.item_total = line_items.sum(&:amount)
        order.item_count = line_items.sum(&:quantity)
        order.promo_total = (line_items + order.shipments.reject(&:marked_for_destruction?)).sum(&:promo_total)
        order.adjustment_total = order.promo_total

        order
      end

      private

      def perform_order_benefits(lane_benefits, lane)
        lane_benefits.filter_map do |benefit|
          benefit.respond_to?(:perform) && benefit.perform(order)
        end

        order.line_items.filter_map do |line_item|
          line_item.managed_by_order_benefit &&
            line_item.managed_by_order_benefit.promotion.lane == lane &&
            !line_item.managed_by_order_benefit.in?(lane_benefits) &&
            line_item.managed_by_order_benefit.remove_from(order)
        end
      end

      def adjust_line_items(benefits)
        order.discountable_line_items.filter_map do |line_item|
          next unless line_item.variant.product.promotionable?

          discounts = generate_discounts(benefits, line_item)
          chosen_discounts = SolidusPromotions.config.discount_chooser_class.new(discounts).call
          (line_item.current_lane_discounts - chosen_discounts).each(&:mark_for_destruction)
        end
      end

      def adjust_shipments(benefits)
        order.shipments.map do |shipment|
          discounts = generate_discounts(benefits, shipment)
          chosen_discounts = SolidusPromotions.config.discount_chooser_class.new(discounts).call
          (shipment.current_lane_discounts - chosen_discounts).each(&:mark_for_destruction)
        end
      end

      def adjust_shipping_rates(benefits)
        order.shipments.flat_map(&:shipping_rates).filter_map do |rate|
          next unless rate.cost

          discounts = generate_discounts(benefits, rate)
          chosen_discounts = SolidusPromotions.config.discount_chooser_class.new(discounts).call
          (rate.current_lane_discounts - chosen_discounts).each(&:mark_for_destruction)
        end
      end

      def eligible_benefits_for_promotable(possible_benefits, promotable)
        possible_benefits.select do |candidate|
          candidate.eligible_by_applicable_conditions?(promotable, dry_run: dry_run)
        end
      end

      def generate_discounts(possible_benefits, item)
        eligible_benefits = eligible_benefits_for_promotable(possible_benefits, item)
        eligible_benefits.filter_map do |benefit|
          benefit.can_discount?(item) && benefit.discount(item)
        end
      end
    end
  end
end
