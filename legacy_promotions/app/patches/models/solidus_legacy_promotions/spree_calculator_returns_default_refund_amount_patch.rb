# frozen_string_literal: true

module SolidusLegacyPromotions
  module SpreeCalculatorReturnsDefaultRefundAmountPatch
    private

    def weighted_order_adjustment_amount(inventory_unit)
      inventory_unit.order.adjustments.eligible.non_tax.sum(:amount) * percentage_of_order_total(inventory_unit)
    end

    Spree::Calculator::Returns::DefaultRefundAmount.prepend self
  end
end
