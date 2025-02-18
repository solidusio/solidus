# frozen_string_literal: true

module Spree
  class Payment < Spree::Base
    module Processing
      # "process!" means:
      #   - Do nothing when:
      #     - There is no payment method
      #     - The payment method does not require a source
      #     - The payment is in the "processing" state
      #     - 'auto_capture?' is false and the payment is already authorized.
      #   - Raise an exception when:
      #     - The source is missing or invalid
      #     - The payment is in a state that cannot transition to 'processing'
      #       (failed/void/invalid states). Note: 'completed' can transition to
      #       'processing' and thus calling #process! on a completed Payment
      #       will attempt to re-authorize/re-purchase the payment.
      #   - Otherwise:
      #     - If 'auto_capture?' is true:
      #       - Call #purchase on the payment gateway. (i.e. authorize+capture)
      #         even if the payment is already completed.
      #     - Else:
      #       - Call #authorize on the payment gateway even if the payment is
      #         already completed.
      def process!
        return if payment_method.nil?

        if payment_method.auto_capture?
          purchase!
        elsif pending?
          # do nothing. already authorized.
        else
          authorize!
        end
      end

      def authorize!
        return unless check_payment_preconditions!

        started_processing!

        protect_from_connection_error do
          response = payment_method.authorize(
            money.money.cents,
            source,
            gateway_options
          )
          pend! if handle_response(response)
        end
      end

      # Captures the entire amount of a payment.
      def purchase!
        return unless check_payment_preconditions!

        started_processing!

        protect_from_connection_error do
          response = payment_method.purchase(
            money.money.cents,
            source,
            gateway_options
          )
          complete! if handle_response(response)
        end

        capture_events.create!(amount:)
      end

      # Takes the amount in cents to capture.
      # Can be used to capture partial amounts of a payment, and will create
      # a new pending payment record for the remaining amount to capture later.
      def capture!(capture_amount = nil)
        return true if completed?
        return false unless amount.positive?

        capture_amount ||= money.money.cents
        started_processing!
        protect_from_connection_error do
          # Standard ActiveMerchant capture usage
          response = payment_method.capture(
            capture_amount,
            response_code,
            gateway_options
          )
          money = ::Money.new(capture_amount, currency)
          capture_events.create!(amount: money.to_d)
          update!(amount: captured_amount)
          complete! if handle_response(response)
        end
      end

      def void_transaction!
        return true if void?
        return false unless amount.positive?

        protect_from_connection_error do
          response = if payment_method.payment_profiles_supported?
            # Gateways supporting payment profiles will need access to credit card object because this stores the payment profile information
            # so supply the authorization itself as well as the credit card, rather than just the authorization code
            payment_method.void(response_code, source, gateway_options)
          else
            # Standard ActiveMerchant void usage
            payment_method.void(response_code, gateway_options)
          end

          handle_void_response(response)
        end
      end

      def cancel!
        Spree::Config.payment_canceller.cancel(self)
      end

      def gateway_options
        order.reload
        options = {
          email: order.email,
          customer: order.email,
          customer_id: order.user_id,
          ip: order.last_ip_address,
          # Need to pass in a unique identifier here to make some
          # payment gateways happy.
          #
          # For more information, please see Spree::Payment#set_unique_identifier
          order_id: gateway_order_id,
          # The originator is passed to options used by the payment method.
          # One example of a place that it is used is in:
          # app/models/spree/payment_method/store_credit.rb
          originator: self
        }

        options[:shipping] = order.ship_total * 100
        options[:tax] = order.additional_tax_total * 100
        options[:subtotal] = order.item_total * 100
        options[:discount] = order.promo_total * 100
        options[:currency] = currency

        bill_address = source.try(:address)
        bill_address ||= order.bill_address

        options[:billing_address] = bill_address&.active_merchant_hash
        options[:shipping_address] = order.ship_address&.active_merchant_hash

        options
      end

      # The unique identifier to be passed in to the payment gateway
      def gateway_order_id
        "#{order.number}-#{number}"
      end

      def handle_void_response(response)
        record_response(response)

        if response.success?
          self.response_code = response.authorization
          void
        else
          gateway_error(response)
        end
      end

      private

      # @raises Spree::Core::GatewayError
      def check_payment_preconditions!
        return if processing?
        return unless payment_method
        return unless payment_method.source_required?

        unless source
          gateway_error(I18n.t("spree.payment_processing_failed"))
        end

        unless payment_method.supports?(source)
          invalidate!
          gateway_error(I18n.t("spree.payment_method_not_supported"))
        end

        true
      end

      # @returns true if the response is successful
      # @returns false (and calls #failure) if the response is not successful
      def handle_response(response)
        record_response(response)

        unless response.success?
          failure
          gateway_error(response)
          return false
        end

        unless response.authorization.nil?
          self.response_code = response.authorization
          self.avs_response = response.avs_result["code"]

          if response.cvv_result
            self.cvv_response_code = response.cvv_result["code"]
            self.cvv_response_message = response.cvv_result["message"]
          end
        end

        true
      end

      def record_response(response)
        log_entries.create!(parsed_payment_response_details_with_fallback: response)
      end

      def protect_from_connection_error
        yield
      rescue ActiveMerchant::ConnectionError => error
        gateway_error(error)
      end

      def gateway_error(error)
        message, log = case error
        when ActiveMerchant::Billing::Response
          [
            error.params["message"] || error.params["response_reason_text"] || error.message,
            basic_response_info(error)
          ]
        when ActiveMerchant::ConnectionError
          [I18n.t("spree.unable_to_connect_to_gateway")] * 2
        else
          [error.to_s, error]
        end

        logger.error("#{I18n.t("spree.gateway_error")}: #{log}")
        raise Core::GatewayError.new(message)
      end

      # The gateway response information without the params since the params
      # can contain PII.
      def basic_response_info(response)
        {
          message: response.message,
          test: response.test,
          authorization: response.authorization,
          avs_result: response.avs_result,
          cvv_result: response.cvv_result,
          error_code: response.error_code,
          emv_authorization: response.emv_authorization,
          gateway_order_id:,
          order_number: order.number
        }
      end
    end
  end
end
