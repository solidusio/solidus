module Spree
  class OrderMailer < BaseMailer
    def confirm_email(order, resend = false)
      @order = order
      @store = @order.store
      subject = build_subject(Spree.t('order_mailer.confirm_email.subject'), resend)

      mail(to: @order.email, from: from_address(@store), subject: subject)
    end

    def cancel_email(order, resend = false)
      @order = order
      @store = @order.store
      subject = build_subject(Spree.t('order_mailer.cancel_email.subject'), resend)

      mail(to: @order.email, from: from_address(@store), subject: subject)
    end

    def inventory_cancellation_email(order, inventory_units, resend = false)
      @order, @inventory_units = order, inventory_units
      @store = @order.store
      subject = build_subject(Spree.t('order_mailer.inventory_cancellation.subject'), resend)

      mail(to: @order.email, from: from_address(@store), subject: subject)
    end

    private

    def build_subject(subject_text, resend)
      resend_text = (resend ? "[#{Spree.t(:resend).upcase}] " : '')
      "#{resend_text}#{@order.store.name} #{subject_text} ##{@order.number}"
    end
  end
end
