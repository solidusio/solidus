# frozen_string_literal: true

module Spree
  # Mailing after {Spree::Carton} is created.
  class CartonShippedMailerSubscriber
    include Omnes::Subscriber

    handle :carton_shipped,
           with: :send_carton_shipped_emails,
           id: :spree_carton_mailer_send_carton_shipped_email

    # Sends carton shipped emails to users.
    #
    # @param event [Omnes::UnstructuredEvent]
    def send_carton_shipped_emails(event)
      carton = event[:carton]

      return if carton.suppress_email

      # Do not send emails for unfulfillable cartons (i.e. for digital goods).
      return unless carton.stock_location.fulfillable?

      carton.orders.each do |order|
        Spree::Config.carton_shipped_email_class
          .shipped_email(order:, carton:)
          .deliver_later
      end
    end
  end
end
