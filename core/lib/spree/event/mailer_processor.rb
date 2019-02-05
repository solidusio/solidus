module Spree
  module Event
    module MailerProcessor
      extend self

      def register!
        ActiveSupport::Notifications.subscribe 'spree.order.confirm_notification' do |*args|
          data = args.extract_options!
          Spree::Config.order_mailer_class.confirm_email(data[:order]).deliver_later
        end
      end
    end
  end
end
