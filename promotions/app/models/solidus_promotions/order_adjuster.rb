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
      order.reset_current_discounts

      return order unless SolidusPromotions::Promotion.order_activatable?(order)

      discounted_order = DiscountOrder.new(order, promotions, dry_run: dry_run).call

      PersistDiscountedOrder.new(discounted_order).call unless dry_run

      order.reset_current_discounts

      unless dry_run
        # Since automations might have added a line item, we need to recalculate item total and item count here.
        order.item_total = order.line_items.sum(&:amount)
        order.item_count = order.line_items.sum(&:quantity)
        order.promo_total = (order.line_items + order.shipments).sum(&:promo_total)
      end
      order
    end
  end
end
