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
        # For payment methods already implemeting `try_void`
        if try_void_available?(payment.payment_method)
          if response = payment.payment_method.try_void(payment)
            payment.send(:handle_void_response, response)
          else
            payment.refunds.create!(amount: payment.credit_allowed, reason: refund_reason, perform_after_create: false).perform!
          end
        else
          # For payment methods not yet implemeting `try_void`
          deprecated_behavior(payment)
        end
      end

      private

      def refund_reason
        Spree::RefundReason.where(name: reason).first_or_create
      end

      def try_void_available?(payment_method)
        payment_method.respond_to?(:try_void) &&
          payment_method.method(:try_void).owner != Spree::PaymentMethod
      end

      def deprecated_behavior(payment)
        Spree::Deprecation.warn "#{payment.payment_method.class.name}#cancel is deprecated and will be removed. " \
          'Please implement a `try_void` method instead that returns a response object if void succeeds ' \
          'or `false|nil` if not. Solidus will refund the payment then.'
        response = payment.payment_method.cancel(payment.response_code)
        payment.send(:handle_void_response, response)
      end
    end
  end
end
