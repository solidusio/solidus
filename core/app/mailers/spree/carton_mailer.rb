module Spree
  class CartonMailer < BaseMailer
    # Send an email to customers to notify that an individual carton has been
    # shipped.
    def shipped_email(order, carton, resend: false)
      @order = order
      @store = order.store
      @carton = carton
      subject = (resend ? "[#{Spree.t(:resend).upcase}] " : '')
      subject += "#{@store.name} #{Spree.t('shipment_mailer.shipped_email.subject')} ##{@order.number}"
      mail(to: @order.email, from: from_address(@store), subject: subject)
    end
  end
end
