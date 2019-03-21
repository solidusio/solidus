# frozen_string_literal: true

module Spree
  module Event
    module Processors
      module MailerProcessor
        SUBSCRIPTIONS = [
          :order_finalized_subscription,
          :reimbursement_reimbursed_subscription
        ]

        mattr_accessor *SUBSCRIPTIONS

        extend self

        def register!
          order_finalized
          reimbursement_reimbursed
        end

        def unregister!
          SUBSCRIPTIONS.each do |subscription|
            Spree::Event.unsubscribe Spree::Event::Processors::MailerProcessor.send(subscription)
          end
        end

        # override if you need to change the existing behavior
        # add new subscriptions via Spree::Event.subscribe if you want to add new behavior
        # unsubsubscribe if you need to remove behavior:
        # Spree::Event.unsubscribe Spree::Event::Processors::MailerProcessor.order_finalized_subscription
        # or Spree::Event::Processors::MailerProcessor.unregister! if you want to remove all these
        # subscriptions
        def order_finalized
          self.order_finalized_subscription = Spree::Event.subscribe 'order_finalized' do |event|
            order = event.payload[:order]
            unless order.confirmation_delivered?
              Spree::Config.order_mailer_class.confirm_email(order).deliver_later
              order.update_column(:confirmation_delivered, true)
            end
          end
        end

        def reimbursement_reimbursed
          self.reimbursement_reimbursed_subscription = Spree::Event.subscribe 'reimbursement_reimbursed' do |event|
            reimbursement = event.payload[:reimbursement]
            Spree::Config.reimbursement_mailer_class.reimbursement_email(reimbursement.id).deliver_later
          end
        end
      end
    end
  end
end
