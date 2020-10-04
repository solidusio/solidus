# frozen_string_literal: true

module Spree
  class ReimbursementMailer < BaseMailer
    def reimbursement_email(reimbursement, resend = false)
      @reimbursement = reimbursement.respond_to?(:id) ? reimbursement : Spree::Reimbursement.find(reimbursement)
      store = @reimbursement.order.store
      subject = (resend ? "[#{t('spree.resend').upcase}] " : '')
      subject += "#{store.name} #{t('.subject')} ##{@reimbursement.order.number}"
      mail(to: @reimbursement.order.email, from: from_address(store), subject: subject)
    end
  end
end
