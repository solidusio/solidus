# frozen_string_literal: true

module Spree
  class ReimbursementType::Credit < Spree::ReimbursementType
    extend Spree::ReimbursementType::ReimbursementHelpers

    class << self
      def reimburse(reimbursement, return_items, simulate, creator: nil)
        unless creator
          creator = Spree.user_class.find_by(email: 'spree@example.com')
          Spree::Deprecation.warn("Calling #reimburse on #{self} without creator is deprecated")
        end
        unpaid_amount = return_items.sum(&:total).round(2, :down)
        reimbursement_list, _unpaid_amount = create_credits(reimbursement, unpaid_amount, simulate, creator: creator)
        reimbursement_list
      end
    end
  end
end
