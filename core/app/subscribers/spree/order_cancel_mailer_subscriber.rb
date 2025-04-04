# frozen_string_literal: true

module Spree
  # Mailing after {Spree::Order} is cancelled.
  class OrderCancelMailerSubscriber
    include Omnes::Subscriber

    handle :order_canceled,
           with: :send_cancel_email,
           id: :spree_order_mailer_send_cancel_email

    # Sends cancellation email to the user.
    #
    # @param event [Omnes::UnstructuredEvent]
    def send_cancel_email(event)
      order = event[:order]

      Spree::Config.order_mailer_class.cancel_email(order).deliver_later
    end
  end
end
