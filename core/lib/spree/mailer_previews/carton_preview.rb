module Spree
  class MailerPreviews
    class CartonPreview < ActionMailer::Preview
      def shipped
        carton = Carton.first
        CartonMailer.shipped_email(order: carton.orders.first, carton: carton)
      end
    end
  end
end
