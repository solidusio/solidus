# frozen_string_literal: true

module Spree
  class OrderMailerSubscriber
    include Omnes::Subscriber

    def send_confirmation_email(_event) = nil
    deprecate send_confirmation_email:
      "Use Spree::OrderConfirmationMailerSubscriber#send_confirmation_email instead",
      deprecator: Spree.deprecator

    def send_reimbursement_email(_event) = nil
    deprecate send_reimbursement_email:
      "use Spree::ReimbursementMailerSubscriber#send_reimbursement_email instead",
      deprecator: Spree.deprecator
  end
end
