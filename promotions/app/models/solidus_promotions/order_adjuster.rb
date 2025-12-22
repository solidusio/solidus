# frozen_string_literal: true

module SolidusPromotions
  class OrderAdjuster
    attr_reader :order, :promotions, :dry_run

    def initialize(order, dry_run_promotion: nil)
      @order = order
      @dry_run = !!dry_run_promotion
      @promotions = SolidusPromotions::LoadPromotions.new(
        order: order,
        dry_run_promotion: dry_run_promotion
      ).call
    end

    def call
      order.reset_current_discounts

      return order unless SolidusPromotions::Promotion.order_activatable?(order)

      discounted_order = DiscountOrder.new(order, promotions, dry_run: dry_run).call

      PersistDiscountedOrder.new(discounted_order).call

      RecalculatePromoTotals.call(discounted_order)
    end
  end
end
