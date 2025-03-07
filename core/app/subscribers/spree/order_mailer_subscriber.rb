# frozen_string_literal: true

module Spree
  # Mailing after events on a {Spree::Order}
  class OrderMailerSubscriber
    include Omnes::Subscriber

    handle :order_finalized,
           with: :send_confirmation_email,
           id: :spree_order_mailer_send_confirmation_email

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

    def send_reimbursement_email(_event) = nil
    deprecate send_reimbursement_email:
      "use Spree::ReimbursementMailerSubscriber#send_reimbursement_email instead",
      deprecator: Spree.deprecator
  end
end
