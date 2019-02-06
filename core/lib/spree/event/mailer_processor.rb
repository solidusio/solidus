module Spree
  module Event
    module MailerProcessor
      extend self

      def register!
        order_finalize
      end

      # override if you need to remove behavior or change the existing behavior
      # add new subscriptions via Event::Subscribe if you want to add new behavior

      def order_finalize
        Spree::Event.subscribe 'order.finalize' do |*args|
          data = args.extract_options!
          order = data[:order]
          unless order.confirmation_delivered?
            Spree::Config.order_mailer_class.confirm_email(order).deliver_later
            order.update_column(:confirmation_delivered, true)
          end
        end
      end
    end
  end
end
