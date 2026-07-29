# frozen_string_literal: true

module Spree
  class OrderContents < Spree::SimpleOrderContents
    # Updates the order's line items with the params passed in.
    # Also runs the PromotionHandler::Cart.
    def update_cart(params)
      if order.update(params)
        unless order.completed?
          order.line_items = order.line_items.select { |li| li.quantity > 0 }
          order.check_shipments_and_restart_checkout
          # Update totals, then check if the order is eligible for any cart promotions.
          # If we do not update first, then the item total will be wrong and ItemTotal
          # promotion rules would not be triggered.
          reload_totals
          apply_cart_promotions
        end
        # Incomplete orders were already recalculated above, only when something changed.
        reload_totals if order.completed?
        true
      else
        false
      end
    end

    private

    def after_add_or_remove(line_item, options = {})
      shipment = options[:shipment]
      shipment.present? ? shipment.update_amounts : order.check_shipments_and_restart_checkout
      reload_totals
      apply_cart_promotions(line_item)
      line_item
    end

    def apply_cart_promotions(line_item = nil)
      # Only the promotions that actually changed an adjustment invalidate the totals above.
      promotion_applied = ::Spree::PromotionHandler::Cart.new(order, line_item).activate
      reload_totals if promotion_applied
    end
  end
end
