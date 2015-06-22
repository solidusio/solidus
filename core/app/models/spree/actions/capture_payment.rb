module Spree
  module Actions
    class CapturePayment < Action
      attr_reader :payment

      def initialize(payment, amount: nil)
        @payment = payment
        @amount = amount
      end

      def amount
        @amount ||= payment.money.money.cents
      end

      def perform
        return true if payment.completed?
        payment.started_processing!
        begin
          #payment.check_environment
          # Standard ActiveMerchant capture usage
          response = payment.payment_method.capture(
            amount,
            payment.response_code,
            payment.gateway_options
          )
          money = ::Money.new(amount, payment.currency)
          payment.capture_events.create!(amount: money.to_f)
          payment.update_attributes(amount: payment.captured_amount)
          payment.handle_response(response, :complete, :failure)
        rescue ActiveMerchant::ConnectionError => e

        end
      end
    end
  end
end
