module Spree
  class MailerPreviews
    class OrderPreview < ActionMailer::Preview
      def confirm
        OrderMailer.confirm_email(Order.first)
      end

      def cancel
        OrderMailer.cancel_email(Order.first)
      end

      def inventory_cancellation
        order = Order.first
        OrderMailer.inventory_cancellation_email(order, [order.inventory_units.first])
      end
    end
  end
end
