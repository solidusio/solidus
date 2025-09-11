# frozen_string_literal: true

module Spree
  # Mailing after a reimbursement is successful for a {Spree::Order}
  class ReimbursementMailerSubscriber
    include Omnes::Subscriber

    handle :reimbursement_reimbursed,
      with: :send_reimbursement_email,
      id: :spree_order_mailer_send_reimbursement_email

    # Sends reimbursement email to the user
    #
    # @param event [Omnes::UnstructuredEvent]
    def send_reimbursement_email(event)
      reimbursement = event[:reimbursement]
      Spree::Config.reimbursement_mailer_class.reimbursement_email(reimbursement.id).deliver_later
    end
  end
end
