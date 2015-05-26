module Spree
  class OrderMailer < BaseMailer
    def confirm_email(order, resend = false)
      @order = order.respond_to?(:id) ? order : Spree::Order.find(order)
      subject = (resend ? "[#{Spree.t(:resend).upcase}] " : '')
      subject += "#{Spree::Store.current.name} #{Spree.t('order_mailer.confirm_email.subject')} ##{@order.number}"
      mail(to: @order.email, from: from_address, subject: subject)
    end

    def cancel_email(order, resend = false)
      @order = order.respond_to?(:id) ? order : Spree::Order.find(order)
      subject = (resend ? "[#{Spree.t(:resend).upcase}] " : '')
      subject += "#{Spree::Store.current.name} #{Spree.t('order_mailer.cancel_email.subject')} ##{@order.number}"
      mail(to: @order.email, from: from_address, subject: subject)
    end

    def inventory_cancellation_email(order, inventory_units, resend = false)
      @order = order
      @inventory_units = inventory_units

      subject = (resend ? "[#{Spree.t(:resend).upcase}] " : '')
      subject += "#{Spree::Config[:site_name]} #{Spree.t('order_mailer.inventory_cancellation.subject')} ##{@order.number}"
      mail(to: @order.email, from: from_address, subject: subject)
    end
  end
end
