module Spree
  class MailerPreviews
    class ReimbursementPreview < ActionMailer::Preview
      def reimbursement
        reimbursement = Reimbursement.last
        raise "Your database needs at least one Reimbursement to render this preview" unless reimbursement
        Spree::NotificationDispatch::ActionMailerDispatch.new(:reimbursement_processed).action_mail_object(reimbursement)
      end
    end
  end
end
