module Spree
  class CartonMailer < BaseMailer
    # Send an email to customers to notify that an individual carton has been
    # shipped.
    def shipped_email(carton_id, resend: false)
      @carton = Spree::Carton.find(carton_id)
      subject = (resend ? "[#{Spree.t(:resend).upcase}] " : '')
      subject += "#{Spree::Config[:site_name]} #{Spree.t('shipment_mailer.shipped_email.subject')} ##{@carton.order_numbers.join(', ')}"
      mail(to: @carton.order_emails, from: from_address, subject: subject)
    end
  end
end
