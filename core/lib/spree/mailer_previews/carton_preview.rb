module Spree
  class MailerPreviews
    class CartonPreview < ActionMailer::Preview
      def shipped
        carton = Carton.first
        CartonMailer.shipped_email(carton.orders.first, carton)
      end
    end
  end
end
