# frozen_string_literal: true

module SolidusPromotions
  class PromotionEligibilityChecker
    attr_reader :promotion

    def initialize(order:, promotion:)
      @order = order
      @promotion = promotion
    end

    def call
      SolidusPromotions::PromotionLane.set(current_lane: promotion.lane) do
        promotion.benefits.each do |benefit|
          benefit.eligible_by_applicable_conditions?(order, dry_run: true)
          order.line_items.each do |line_item|
            check_item(line_item, benefit)
          end
          order.shipments.each do |shipment|
            check_item(shipment, benefit)
          end
        end
      end
    end

    private

    attr_reader :order

    def check_item(item, benefit)
      benefit.can_discount?(item) &&
        benefit.eligible_by_applicable_conditions?(item, dry_run: true)
    end
  end
end
