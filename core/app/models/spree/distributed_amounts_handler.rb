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
      Hash[line_item_ids.zip(allocated_amounts)]
    end

    def line_item_ids
      @order.line_items.map(&:id)
    end

    def line_item_amounts
      @order.line_items.map(&:amount)
    end

    def subtotal
      line_item_amounts.sum
    end

    def weights
      line_item_amounts.map { |amount| amount.to_f / subtotal.to_f }
    end

    def allocated_amounts
      @total_amount.to_money.allocate(weights)
    end
  end
end
