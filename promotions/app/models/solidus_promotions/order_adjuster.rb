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
      return order unless SolidusPromotions::Promotion.order_activatable?(order)

      NullifyOrderDiscounts.new(order:).call

      DiscountOrder.new(order, promotions, dry_run: dry_run).call

      CleanDiscountedOrder.new(order).call

      RecalculatePromoTotals.new(order).call
    end
  end
end
