# frozen_string_literal: true

module SolidusPromotions
  class PromotionEligibilityChecker
    attr_reader :results

    def initialize(order:, promotion:)
      @order = order
      @promotion = promotion
      @results = SolidusPromotions::EligibilityResults.new(promotion)
    end

    def call
      SolidusPromotions::PromotionLane.set(current_lane: promotion.lane) do
        promotion.benefits.any? do |benefit|
          # We're running this first and storing the result so the following
          # block does not short-circuit on ineligible items, and we get all errors.
          order_eligible = applicable_conditions_eligible?(order, benefit)
          (
            order.line_items.any? do |line_item|
              check_item(line_item, benefit)
            end || order.shipments.any? do |shipment|
              check_item(shipment, benefit)
            end
          ) && order_eligible
        end
      end
    end

    private

    attr_reader :order, :promotion

    def check_item(item, benefit)
      benefit.can_discount?(item) &&
        applicable_conditions_eligible?(item, benefit)
    end

    def applicable_conditions_eligible?(item, benefit)
      benefit.conditions.map do |condition|
        next unless condition.applicable?(item)
        eligible = !!condition.eligible?(item)

        if condition.eligibility_errors.details[:base].first
          code = condition.eligibility_errors.details[:base].first[:error_code]
          message = condition.eligibility_errors.full_messages.first
        end
        results.add(
          item: item,
          condition: condition,
          success: eligible,
          code: eligible ? nil : (code || :coupon_code_unknown_error),
          message: eligible ? nil : (message || I18n.t(:coupon_code_unknown_error, scope: [:solidus_promotions, :eligibility_errors]))
        )

        eligible
      end.compact.all?
    end
  end
end
