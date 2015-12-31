module Solidus
  class OrderMailer < BaseMailer
    def confirm_email(order, resend = false)
      @order = find_order(order)
      @store = @order.store
      subject = build_subject(Solidus.t('order_mailer.confirm_email.subject'), resend)

      mail(to: @order.email, from: from_address(@store), subject: subject)
    end

    def cancel_email(order, resend = false)
      @order = find_order(order)
      @store = @order.store
      subject = build_subject(Solidus.t('order_mailer.cancel_email.subject'), resend)

      mail(to: @order.email, from: from_address(@store), subject: subject)
    end

    def inventory_cancellation_email(order, inventory_units, resend = false)
      @order, @inventory_units = find_order(order), inventory_units
      @store = @order.store
      subject = build_subject(Solidus.t('order_mailer.inventory_cancellation.subject'), resend)

      mail(to: @order.email, from: from_address(@store), subject: subject)
    end

    private

    def find_order(order)
      if order.respond_to?(:id)
        order
      else
        ActiveSupport::Deprecation.warn("Calling OrderMailer with an id is deprecated. Pass the Solidus::Order object instead.")
        Solidus::Order.find(order)
      end
    end

    def build_subject(subject_text, resend)
      subject = (resend ? "[#{Solidus.t(:resend).upcase}] " : '')
      subject += "#{Solidus::Store.current.name} #{subject_text} ##{@order.number}"
    end
  end
end
