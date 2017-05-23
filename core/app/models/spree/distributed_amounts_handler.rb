module Spree
  class DistributedAmountsHandler
    attr_reader :line_item, :order, :total_amount

    def initialize(line_item, total_amount)
      @line_item = line_item
      @order = line_item.order
      @total_amount = total_amount
    end

    # @return [Float] the weighted adjustment for the initialized line item
    def amount
      distributed_amounts[@line_item.id].to_f
    end

    private

    # @private
    # @return [Hash<Integer, BigDecimal>] a hash of line item IDs and their
    #   corresponding weighted adjustments
    def distributed_amounts
      remaining_amount = @total_amount

      @order.line_items.each_with_index.map do |line_item, i|
        if i == @order.line_items.length - 1
          # If this is the last line item on the order we want to use the
          # remaining preferred amount to ensure our total adjustment is what
          # has been set as the preferred amount.
          [line_item.id, remaining_amount]
        else
          # Calculate the weighted amount by getting this line item's share of
          # the order's total and multiplying it with the preferred amount.
          weighted_amount = ((line_item.amount / @order.item_total) * total_amount).round(2)

          # Subtract this line item's weighted amount from the total.
          remaining_amount -= weighted_amount

          [line_item.id, weighted_amount]
        end
      end.to_h
    end
  end
end
