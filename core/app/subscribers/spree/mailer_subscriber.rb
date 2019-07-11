# frozen_string_literal: true

require 'spree/event/subscriber'

module Spree
  module MailerSubscriber
    include Spree::Event::Subscriber

    event_action :order_finalized
    event_action :send_reimbursement_email, event_name: :reimbursement_reimbursed

    def order_finalized(event)
      order = event.payload[:order]
      unless order.confirmation_delivered?
        Spree::Config.order_mailer_class.confirm_email(order).deliver_later
        order.update_column(:confirmation_delivered, true)
      end
    end

    def send_reimbursement_email(event)
      reimbursement = event.payload[:reimbursement]
      Spree::Config.reimbursement_mailer_class.reimbursement_email(reimbursement.id).deliver_later
    end
  end
end
