# frozen_string_literal: true

module Spree
  # Mailing after events on a {Spree::Order}
  class OrderMailerSubscriber
    include Omnes::Subscriber

    handle :order_finalized,
           with: :send_confirmation_email,
           id: :spree_order_mailer_send_confirmation_email

    handle :reimbursement_reimbursed,
           with: :send_reimbursement_email,
           id: :spree_order_mailer_send_reimbursement_email

    # Sends confirmation email to the user
    #
    # @param event [Omnes::UnstructuredEvent]
    def send_confirmation_email(event)
      order = event[:order]
      unless order.confirmation_delivered?
        Spree::Config.order_mailer_class.confirm_email(order).deliver_later
        order.update_column(:confirmation_delivered, true)
      end
    end

    # Sends reimbursement email to the user
    #
    # @param event [Omnes::UnstructuredEvent]
    def send_reimbursement_email(event)
      reimbursement = event[:reimbursement]
      Spree::Config.reimbursement_mailer_class.reimbursement_email(reimbursement.id).deliver_later
    end
  end
end
