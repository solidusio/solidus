module Spree
  class CartonMailer < BaseMailer
    # Send an email to customers to notify that an individual carton has been
    # shipped.
    def shipped_email(options, deprecated_options={})
      if options.is_a?(Integer)
        ActiveSupport::Deprecation.warn "Calling shipped_email with a carton_id is DEPRECATED. Instead use CartonMailer.shipped_email(order: order, carton: carton)"
        @carton = Carton.find(options)
        @order = @carton.orders.first # assume first order
        @manifest = @carton.manifest # use the entire manifest, since we don't know the precise order
        options = deprecated_options
      else
        @order = options.fetch(:order)
        @carton = options.fetch(:carton)
        @manifest = @carton.manifest_for_order(@order)
      end
      options =  {resend: false}.merge(options)
      @store = @order.store
      subject = (options[:resend] ? "[#{Spree.t(:resend).upcase}] " : '')
      subject += "#{@store.name} #{Spree.t('shipment_mailer.shipped_email.subject')} ##{@order.number}"
      mail(to: @order.email, from: from_address(@store), subject: subject)
    end
  end
end
