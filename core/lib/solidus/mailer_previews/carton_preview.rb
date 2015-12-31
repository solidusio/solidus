module Spree
  class MailerPreviews
    class CartonPreview < ActionMailer::Preview
      def shipped
        carton = Carton.first
        Spree::Config.carton_shipped_email_class.shipped_email(order: carton.orders.first, carton: carton)
      end
    end
  end
end
