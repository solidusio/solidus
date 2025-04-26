# frozen_string_literal: true

module Spree
  # Mailing after inventory units have been cancelled from a {Spree::Order}
  class OrderInventoryCancellationMailerSubscriber
    include Omnes::Subscriber

    handle :order_short_shipped,
           with: :send_inventory_cancellation_email,
           id: :spree_order_mailer_send_inventory_cancellation_email

    # Sends inventory cancellation email to the user.
    #
    # @param event [Omnes::UnstructuredEvent]
    def send_inventory_cancellation_email(event)
      return unless Spree::OrderCancellations.send_cancellation_mailer

      order = event[:order]
      inventory_units = event[:inventory_units]

      Spree::Config
        .order_mailer_class
        .inventory_cancellation_email(order, inventory_units.to_a)
        .deliver_later
    end
  end
end
