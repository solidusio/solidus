# frozen_string_literal: true

module SolidusFriendlyPromotions
  class FriendlyPromotionDiscounter
    attr_reader :order, :promotions, :collect_eligibility_results

    def initialize(order, promotions, collect_eligibility_results: false)
      @order = order
      @promotions = promotions
      @collect_eligibility_results = collect_eligibility_results
    end

    def call
      return order if order.shipped?

      order.reset_current_discounts

      SolidusFriendlyPromotions::Promotion.ordered_lanes.each do |lane, _index|
        lane_promotions = eligible_promotions_for_promotable(promotions.select { |promotion| promotion.lane == lane }, order)
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

    def adjust_line_items(promotions)
      order.line_items.select do |line_item|
        line_item.variant.product.promotionable?
      end.map do |line_item|
        discounts = generate_discounts(promotions, line_item)
        chosen_item_discounts = SolidusFriendlyPromotions.config.discount_chooser_class.new(line_item).call(discounts)
        [line_item, chosen_item_discounts]
      end
    end

    def adjust_shipments(promotions)
      order.shipments.map do |shipment|
        discounts = generate_discounts(promotions, shipment)
        chosen_item_discounts = SolidusFriendlyPromotions.config.discount_chooser_class.new(shipment).call(discounts)
        [shipment, chosen_item_discounts]
      end
    end

    def adjust_shipping_rates(promotions)
      order.shipments.flat_map(&:shipping_rates).map do |rate|
        discounts = generate_discounts(promotions, rate)
        chosen_item_discounts = SolidusFriendlyPromotions.config.discount_chooser_class.new(rate).call(discounts)
        [rate, chosen_item_discounts]
      end
    end

    def eligible_promotions_for_promotable(possible_promotions, promotable)
      possible_promotions.select do |candidate|
        PromotionEligibility.new(promotable: promotable, promotion: candidate, collect_eligibility_results: collect_eligibility_results).call
      end
    end

    def generate_discounts(possible_promotions, item)
      eligible_promotions = eligible_promotions_for_promotable(possible_promotions, item)
      eligible_promotions.flat_map do |promotion|
        promotion.actions.select do |action|
          action.can_discount?(item)
        end.map do |action|
          action.discount(item)
        end
      end
    end
  end
end
