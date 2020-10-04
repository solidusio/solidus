# frozen_string_literal: true

module Spree
  class CartonMailer < BaseMailer
    # Send an email to customers to notify that an individual carton has been
    # shipped. If a carton contains items from multiple orders then this will be
    # called with that carton one time for each order.
    #
    # @option options carton [Spree::Carton] the shipped carton
    # @option options order [Spree::Order] one of the orders with items in the carton
    # @option options resend [Boolean] indicates whether the email is a 'resend' (e.g.
    #   triggered by the admin "resend" button)
    # @return [Mail::Message]
    #
    # Note: The signature of this method has changed. The new (non-deprecated)
    # signature is:
    #   def shipped_email(carton:, order:, resend: false)
    def shipped_email(options, _deprecated_options = {})
      @order = options.fetch(:order)
      @carton = options.fetch(:carton)
      @manifest = @carton.manifest_for_order(@order)
      options = { resend: false }.merge(options)
      @store = @order.store
      subject = (options[:resend] ? "[#{t('spree.resend').upcase}] " : '')
      subject += "#{@store.name} #{t('spree.shipment_mailer.shipped_email.subject')} ##{@order.number}"
      mail(to: @order.email, from: from_address(@store), subject: subject)
    end
  end
end
