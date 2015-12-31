module Solidus
  class ReimbursementMailer < BaseMailer
      def reimbursement_email(reimbursement, resend = false)
        @reimbursement = reimbursement.respond_to?(:id) ? reimbursement : Solidus::Reimbursement.find(reimbursement)
        store = @reimbursement.order.store
        subject = (resend ? "[#{Solidus.t(:resend).upcase}] " : '')
        subject += "#{store.name} #{Solidus.t('reimbursement_mailer.reimbursement_email.subject')} ##{@reimbursement.order.number}"
        mail(to: @reimbursement.order.email, from: from_address(store), subject: subject)
      end
  end
end
