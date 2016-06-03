module Spree
  class MailerPreviews
    class CartonPreview < ActionMailer::Preview
      def shipped
        carton = Carton.joins(:orders).last
        raise "Your database needs at one shipped order with a carton to render this preview" unless carton
        Spree::NotificationDispatch::ActionMailerDispatcher.new(:carton_shipped).action_mail_object(order: carton.orders.first, carton: carton)
      end
    end
  end
end
