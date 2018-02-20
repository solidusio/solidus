# frozen_string_literal: true

module Spree
  class MailerPreviews
    class CartonPreview < ActionMailer::Preview
      def shipped
        carton = Carton.joins(:orders).last
        raise "Your database needs at one shipped order with a carton to render this preview" unless carton
        Spree::Config.carton_shipped_email_class.shipped_email(order: carton.orders.first, carton: carton)
      end
    end
  end
end
