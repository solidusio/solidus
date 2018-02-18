module Spree
  class DistributedAmountsHandler
    attr_reader :line_item, :order, :promotion, :total_amount

    def initialize(line_item, promotion, total_amount)
      @line_item = line_item
      @order = line_item.order
      @promotion = promotion
      @total_amount = total_amount
    end

    # @return [BigDecimal] the weighted adjustment for the initialized line item
    def amount
      distributed_amounts[@line_item.id].to_d
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

    def elligible_amounts
      @order.line_items.map do |line_item|
        elligible = promotion.line_item_actionable?(line_item.order, line_item)
        elligible ? line_item.amount : 0
      end
    end

    def subtotal
      elligible_amounts.sum
    end

    def weights
      elligible_amounts.map { |amount| amount.to_f / subtotal.to_f }
    end

    def allocated_amounts
      @total_amount.to_money.allocate(weights).map(&:to_money)
    end
  end
end
