module Spree
  class MailerPreviews
    class ReimbursementPreview < ActionMailer::Preview
      def reimbursement
        reimbursement = Reimbursement.last
        raise "Your database needs at least one Reimbursement to render this preview" unless reimbursement
        ReimbursementMailer.reimbursement_email(reimbursement)
      end
    end
  end
end
