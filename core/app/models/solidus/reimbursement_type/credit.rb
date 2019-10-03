# frozen_string_literal: true

module Solidus
  class ReimbursementType::Credit < Solidus::ReimbursementType
    extend Solidus::ReimbursementType::ReimbursementHelpers

    class << self
      def reimburse(reimbursement, return_items, simulate, created_by: nil)
        unless created_by
          Solidus::Deprecation.warn("Calling #reimburse on #{self} without created_by is deprecated")
        end
        unpaid_amount = return_items.sum(&:total).round(2, :down)
        reimbursement_list, _unpaid_amount = create_credits(reimbursement, unpaid_amount, simulate, created_by: created_by)
        reimbursement_list
      end
    end
  end
end
