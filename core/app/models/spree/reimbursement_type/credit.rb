# frozen_string_literal: true

module Spree
  class ReimbursementType::Credit < Spree::ReimbursementType
    extend Spree::ReimbursementType::ReimbursementHelpers

    class << self
      def reimburse(reimbursement, reimbursement_items, simulate)
        unpaid_amount = reimbursement_items.sum(&:total).round(2, :down)
        reimbursement_list, _unpaid_amount = create_credits(reimbursement, unpaid_amount, simulate)
        reimbursement_list
      end
    end
  end
end
