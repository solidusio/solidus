# frozen_string_literal: true

module Spree
  class OrderContents < Spree::SimpleOrderContents
    # Updates the order's line items with the params passed in.
    # Also runs the PromotionHandler::Cart.
    def update_cart(params)
      if order.update(params)
        unless order.completed?
          order.line_items = order.line_items.select { |li| li.quantity > 0 }
          # Update totals, then check if the order is eligible for any cart promotions.
          # If we do not update first, then the item total will be wrong and ItemTotal
          # promotion rules would not be triggered.
          reload_totals
          order.check_shipments_and_restart_checkout
          ::Spree::PromotionHandler::Cart.new(order).activate
        end
        reload_totals
        true
      else
        false
      end
    end

    private

    def after_add_or_remove(line_item, options = {})
      reload_totals
      shipment = options[:shipment]
      shipment.present? ? shipment.update_amounts : order.check_shipments_and_restart_checkout
      ::Spree::PromotionHandler::Cart.new(order, line_item).activate
      reload_totals
      line_item
    end
  end
end
