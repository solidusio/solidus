# frozen_string_literal: true

module SolidusFriendlyPromotions
  class FriendlyPromotionAdjuster
    attr_reader :order, :promotions, :dry_run

    def initialize(order, additional_promotion: nil)
      @order = order
      @dry_run = !!additional_promotion
      @promotions = LoadPromotions.new(order: order, additional_promotion: additional_promotion).call
    end

    def call
      order.reset_current_discounts

      return order if order.shipped?
      discounted_order = DiscountOrder.new(order, promotions, collect_eligibility_results: dry_run).call

      PersistDiscountedOrder.new(discounted_order).call unless dry_run

      order.reset_current_discounts
      order
    end
  end
end
