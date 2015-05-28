module Spree
  class OrderMailer < BaseMailer
    def confirm_email(order, resend = false)
      @order = find_order(order)
      subject = build_subject(Spree.t('order_mailer.confirm_email.subject'), resend)

      mail(to: @order.email, from: from_address, subject: subject)
    end

    def cancel_email(order, resend = false)
      @order = find_order(order)
      subject = build_subject(Spree.t('order_mailer.cancel_email.subject'), resend)

      mail(to: @order.email, from: from_address, subject: subject)
    end

    def inventory_cancellation_email(order, inventory_units, resend = false)
      @order, @inventory_units = find_order(order), inventory_units
      subject = build_subject(Spree.t('order_mailer.inventory_cancellation.subject'), resend)

      mail(to: @order.email, from: from_address, subject: subject)
    end

    private

    def find_order(order)
      @order = order.respond_to?(:id) ? order : Spree::Order.find(order)
    end

    def build_subject(subject_text, resend)
      subject = (resend ? "[#{Spree.t(:resend).upcase}] " : '')
      subject += "#{Spree::Config[:site_name]} #{subject_text} ##{@order.number}"
    end
  end
end
