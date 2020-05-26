# frozen_string_literal: true

module Spree
  module ReimbursementType::ReimbursementHelpers
    # Ordered list of payment methods that are valid for the reimbursement
    # type to use for reimbursing. Leaving this nil allows anything.
    attr_accessor :eligible_refund_methods

    def create_refunds(reimbursement, payments, unpaid_amount, simulate, reimbursement_list = [])
      payments = sorted_eligible_refund_payments(payments)
      payments.map do |payment|
        break if unpaid_amount <= 0
        next unless payment.can_credit?

        amount = [unpaid_amount, payment.credit_allowed].min
        reimbursement_list << create_refund(reimbursement, payment, amount, simulate)
        unpaid_amount -= amount
      end

      [reimbursement_list, unpaid_amount]
    end

    def create_credits(reimbursement, unpaid_amount, simulate, reimbursement_list = [], created_by:)
      credits = [create_credit(reimbursement, unpaid_amount, simulate, created_by: created_by)]
      unpaid_amount -= credits.sum(&:amount)
      reimbursement_list += credits

      [reimbursement_list, unpaid_amount]
    end

    private

    def create_refund(reimbursement, payment, amount, simulate)
      refund = reimbursement.refunds.build({
        payment: payment,
        amount: amount,
        reason: Spree::RefundReason.return_processing_reason,
        perform_after_create: false
      })

      if simulate
        refund.readonly!
      else
        refund.save!
        refund.perform!
      end

      refund
    end

    # If you have multiple methods of crediting a customer, overwrite this method
    # Must return an array of objects the respond to #description, #display_amount
    def create_credit(reimbursement, unpaid_amount, simulate, created_by:)
      creditable = create_creditable(reimbursement, unpaid_amount, created_by: created_by)
      credit = reimbursement.credits.build(creditable: creditable, amount: unpaid_amount)
      simulate ? credit.readonly! : credit.save!
      credit
    end

    def create_creditable(reimbursement, unpaid_amount, created_by:)
      Spree::Reimbursement::Credit.default_creditable_class.new(
        user: reimbursement.order.user,
        amount: unpaid_amount,
        category: Spree::StoreCreditCategory.reimbursement_category(reimbursement),
        created_by: created_by,
        memo: "Refund for uncreditable payments on order #{reimbursement.order.number}",
        currency: reimbursement.order.currency
      )
    end

    def sorted_eligible_refund_payments(payments)
      if eligible_refund_methods = self.eligible_refund_methods
        payments = payments.select { |payment| eligible_refund_methods.include? payment.payment_method.class }
        payments = payments.sort_by { |payment| eligible_refund_methods.index(payment.payment_method.class) }
      end
      payments
    end
  end
end
