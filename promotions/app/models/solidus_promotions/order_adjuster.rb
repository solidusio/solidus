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

    def call(persist: true) # rubocop:disable Lint/UnusedMethodArgument
      return order unless SolidusPromotions::Promotion.order_activatable?(order)

      SetDiscountsToZero.call(order)

      DiscountOrder.new(order, promotions, dry_run: dry_run).call

      RecalculatePromoTotals.call(order)
    end
  end
end
