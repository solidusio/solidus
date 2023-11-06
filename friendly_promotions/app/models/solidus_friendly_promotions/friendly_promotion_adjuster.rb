# frozen_string_literal: true

module SolidusFriendlyPromotions
  class FriendlyPromotionAdjuster
    attr_reader :order, :promotions, :dry_run

    def initialize(order, dry_run_promotion: nil)
      @order = order
      @dry_run = !!dry_run_promotion
      @promotions = LoadPromotions.new(order: order, dry_run_promotion: dry_run_promotion).call
    end

    def call
      order.reset_current_discounts

      return order if order.shipped?
      discounted_order = DiscountOrder.new(order, promotions, dry_run: dry_run).call

      PersistDiscountedOrder.new(discounted_order).call unless dry_run

      order.reset_current_discounts
      order
    end
  end
end
