module Spree::Checkout::Blockers
  #
  # Simple class that implement validation that check for whether or not
  # there is at least one LineItem in the Order.
  #
  class LineItemsRequired < Base

    def blocks_checkout?
      !@order.line_items.empty?
    end

  end
end
