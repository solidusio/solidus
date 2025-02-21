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
           id: :deprecated_spree_order_mailer_send_reimbursement_email

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
      Spree.deprecator.warn(
        "The `Spree::OrderMailerSubscriber#send_reimbursement_email` " \
        "method is deprecated and will be removed in Solidus 5.0. Use " \
        "`Spree::ReimbursementMailerSubscriber#send_confirmation_email` " \
        "instead."
      )
      Spree::ReimbursementMailerSubscriber.new.send_reimbursement_email(event)
    end
  end
end
