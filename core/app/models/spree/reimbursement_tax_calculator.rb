# frozen_string_literal: true

module Spree
  # Tax calculation is broken out at this level to allow easy integration with 3rd party
  # taxation systems.  Those systems are usually geared toward calculating all items at once
  # rather than one at a time.
  #
  # To use an alternative tax calculator do this:
  #    Spree::ReturnAuthorization.reimbursement_tax_calculator = calculator_object
  # where `calculator_object` is an object that responds to "call" and accepts a reimbursement object

  class ReimbursementTaxCalculator
    class << self
      def call(reimbursement)
        reimbursement.return_items.includes(:inventory_unit).find_each do |return_item|
          set_tax!(return_item)
        end
      end

      private

      def set_tax!(return_item)
        percent_of_tax = (return_item.amount <= 0) ? 0 : return_item.amount / Spree::ReturnItem.refund_amount_calculator.new.compute(return_item)

        additional_tax_total = percent_of_tax * return_item.inventory_unit.additional_tax_total
        included_tax_total = percent_of_tax * return_item.inventory_unit.included_tax_total

        return_item.update!({
          additional_tax_total:,
          included_tax_total:
        })
      end
    end
  end
end
