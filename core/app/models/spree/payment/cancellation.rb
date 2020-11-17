# frozen_string_literal: true

module Spree
  class Payment
    # Payment cancellation handler
    #
    # Cancels a payment by trying to void first and if that fails
    # creating a refund about the full amount instead.
    #
    class Cancellation
      DEFAULT_REASON = 'Order canceled'.freeze

      attr_reader :reason

      # @param reason [String] (DEFAULT_REASON) -
      #   The reason used to create the Spree::RefundReason
      def initialize(reason: DEFAULT_REASON)
        @reason = reason
      end

      # Cancels a payment
      #
      # Tries to void the payment by asking the payment method to try a void,
      # if that fails create a refund about the allowed credit amount instead.
      #
      # @param payment [Spree::Payment] - the payment that should be canceled
      #
      def cancel(payment)
        if response = payment.payment_method.try_void(payment)
          payment.handle_void_response(response)
        else
          payment.refunds.create!(amount: payment.credit_allowed, reason: refund_reason, perform_after_create: false).perform!
        end
      end

      private

      def refund_reason
        Spree::RefundReason.where(name: reason).first_or_create
      end
    end
  end
end
