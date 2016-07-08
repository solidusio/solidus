module Spree
  class CartonMailer < BaseMailer
    # Send an email to customers to notify that an individual carton has been
    # shipped. If a carton contains items from multiple orders then this will be
    # called with that carton one time for each order.
    #
    # @param carton [Spree::Carton] the shipped carton
    # @param order [Spree::Order] one of the orders with items in the carton
    # @param resend [Boolean] indicates whether the email is a 'resend' (e.g.
    #        triggered by the admin "resend" button)
    # @return [Mail::Message]
    #
    # Note: The signature of this method has changed. The new (non-deprecated)
    # signature is:
    #   def shipped_email(carton:, order:, resend: false)
    def shipped_email(options, deprecated_options = {})
      if options.is_a?(Integer)
        Spree::Deprecation.warn "Calling shipped_email with a carton_id is DEPRECATED. Instead use CartonMailer.shipped_email(order: order, carton: carton)"
        @carton = Carton.find(options)
        @order = @carton.orders.first # assume first order
        @manifest = @carton.manifest # use the entire manifest, since we don't know the precise order
        options = deprecated_options
      else
        @order = options.fetch(:order)
        @carton = options.fetch(:carton)
        @manifest = @carton.manifest_for_order(@order)
      end
      options = { resend: false }.merge(options)
      @store = @order.store
      subject = (options[:resend] ? "[#{Spree.t(:resend).upcase}] " : '')
      subject += "#{@store.name} #{Spree.t('shipment_mailer.shipped_email.subject')} ##{@order.number}"
      mail(to: @order.email, from: from_address(@store), subject: subject)
    end
  end
end
