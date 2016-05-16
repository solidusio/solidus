module Spree
  class MailerPreviews
    class ReimbursementPreview < ActionMailer::Preview
      def reimbursement
        ReimbursementMailer.reimbursement_email(Reimbursement.first)
      end
    end
  end
end
