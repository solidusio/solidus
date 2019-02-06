# frozen_string_literal: true

module Spree
  module Event
    module MailerProcessor
      SUBSCRIPTIONS = [:order_finalize_subscription, :reimbursement_perform_subscription]
      mattr_accessor *SUBSCRIPTIONS

      extend self

      def register!
        order_finalize
        reimbursement_perform
      end

      def unregister!
        SUBSCRIPTIONS.each do |subscription|
          Spree::Event.unsubscribe Spree::Event::MailerProcessor.send(subscription)
        end
      end

      # override if you need to change the existing behavior
      # add new subscriptions via Spree::Event.subscribe if you want to add new behavior
      # unsubsubscribe if you need to remove behavior:
      # Spree::Event.unsubscribe Spree::Event::MailerProcessor.order_finalize_subscription
      # or Spree::Event::MailerProcessor.unregister! if you want to remove all these subscriptions
      def order_finalize
        self.order_finalize_subscription = Spree::Event.subscribe 'order.finalize' do |event|
          order = event.payload[:order]
          unless order.confirmation_delivered?
            Spree::Config.order_mailer_class.confirm_email(order).deliver_later
            order.update_column(:confirmation_delivered, true)
          end
        end
      end

      def reimbursement_perform
        self.reimbursement_perform_subscription = Spree::Event.subscribe 'reimbursement.perform' do |event|
          reimbursement = event.payload[:reimbursement]
          if reimbursement.reimbursed?
            Spree::Config.reimbursement_mailer_class.reimbursement_email(reimbursement.id).deliver_later
          end
        end
      end
    end
  end
end
