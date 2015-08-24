module Spree
  class CartonMailer < BaseMailer
    # Send an email to customers to notify that an individual carton has been
    # shipped.
    def shipped_email(*args)
      options = {resend: false}.merge(args.extract_options!)
      if args.length == 1
        ActiveSupport::Deprecation.warn "Calling shipped_email with a carton_id is DEPRECATED. Instead use CartonMailer.shipped_email(order, carton)"
        @carton = Carton.find(args[0])
        @order = @carton.orders.first # assume first order
        @manifest = @carton.manifest # use the entire manifest, since we don't know the precise order
      else
        @order, @carton = args
        @manifest = @carton.manifest_for_order(@order)
      end
      @store = @order.store
      subject = (options[:resend] ? "[#{Spree.t(:resend).upcase}] " : '')
      subject += "#{@store.name} #{Spree.t('shipment_mailer.shipped_email.subject')} ##{@order.number}"
      mail(to: @order.email, from: from_address(@store), subject: subject)
    end
  end
end
