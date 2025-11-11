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
        order.shipments.flat_map(&:shipping_rates).filter_map do |rate|
          next unless rate.cost

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
        eligible_benefits.filter_map do |benefit|
          benefit.can_discount?(item) && benefit.discount(item)
        end
      end
    end
  end
end
