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
        handle_payment_preconditions { process_authorization }
      end

      # Captures the entire amount of a payment.
      def purchase!
        handle_payment_preconditions { process_purchase }
      end

      # Takes the amount in cents to capture.
      # Can be used to capture partial amounts of a payment, and will create
      # a new pending payment record for the remaining amount to capture later.
      def capture!(amount = nil)
        return true if completed?
        amount ||= money.money.cents
        started_processing!
        protect_from_connection_error do
          # Standard ActiveMerchant capture usage
          response = payment_method.capture(
            amount,
            response_code,
            gateway_options
          )
          money = ::Money.new(amount, currency)
          capture_events.create!(amount: money.to_d)
          update!(amount: captured_amount)
          handle_response(response, :complete, :failure)
        end
      end

      def void_transaction!
        return true if void?
        protect_from_connection_error do
          if payment_method.payment_profiles_supported?
            # Gateways supporting payment profiles will need access to credit card object because this stores the payment profile information
            # so supply the authorization itself as well as the credit card, rather than just the authorization code
            response = payment_method.void(response_code, source, gateway_options)
          else
            # Standard ActiveMerchant void usage
            response = payment_method.void(response_code, gateway_options)
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

        options[:billing_address] = bill_address.try!(:active_merchant_hash)
        options[:shipping_address] = order.ship_address.try!(:active_merchant_hash)

        options
      end

      # The unique identifier to be passed in to the payment gateway
      def gateway_order_id
        "#{order.number}-#{number}"
      end

      private

      def process_authorization
        started_processing!
        gateway_action(source, :authorize, :pend)
      end

      def process_purchase
        started_processing!
        gateway_action(source, :purchase, :complete)
        # This won't be called if gateway_action raises a GatewayError
        capture_events.create!(amount: amount)
      end

      def handle_payment_preconditions(&_block)
        unless block_given?
          raise ArgumentError.new("handle_payment_preconditions must be called with a block")
        end

        return if payment_method.nil?
        return if !payment_method.source_required?

        if source
          if !processing?
            if payment_method.supports?(source)
              yield
            else
              invalidate!
              raise Core::GatewayError.new(I18n.t('spree.payment_method_not_supported'))
            end
          end
        else
          raise Core::GatewayError.new(I18n.t('spree.payment_processing_failed'))
        end
      end

      def gateway_action(source, action, success_state)
        protect_from_connection_error do
          response = payment_method.send(action, money.money.cents,
                                         source,
                                         gateway_options)
          handle_response(response, success_state, :failure)
        end
      end

      def handle_response(response, success_state, failure_state)
        record_response(response)

        if response.success?
          unless response.authorization.nil?
            self.response_code = response.authorization
            self.avs_response = response.avs_result['code']

            if response.cvv_result
              self.cvv_response_code = response.cvv_result['code']
              self.cvv_response_message = response.cvv_result['message']
            end
          end
          send("#{success_state}!")
        else
          send(failure_state)
          gateway_error(response)
        end
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

      def record_response(response)
        log_entries.create!(details: response.to_yaml)
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
                            error.params['message'] || error.params['response_reason_text'] || error.message,
                            basic_response_info(error)
                          ]
                        when ActiveMerchant::ConnectionError
                          [I18n.t('spree.unable_to_connect_to_gateway')] * 2
                        else
                          [error.to_s, error]
                        end

        logger.error("#{I18n.t('spree.gateway_error')}: #{log}")
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
          gateway_order_id: gateway_order_id,
          order_number: order.number
        }
      end
    end
  end
end
