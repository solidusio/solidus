# frozen_string_literal: true

module Spree
  class PaymentMethod::BogusCreditCard < PaymentMethod::CreditCard
    TEST_VISA = ["4111111111111111", "4012888888881881", "4222222222222"]
    TEST_MC = ["5500000000000004", "5555555555554444", "5105105105105100"]
    TEST_AMEX = ["378282246310005", "371449635398431", "378734493671000", "340000000000009"]
    TEST_DISC = ["6011000000000004", "6011111111111117", "6011000990139424"]

    VALID_CCS = ["1", TEST_VISA, TEST_MC, TEST_AMEX, TEST_DISC].flatten

    AUTHORIZATION_CODE = "12345"
    FAILURE_MESSAGE = "Bogus Gateway: Forced failure"
    SUCCESS_MESSAGE = "Bogus Gateway: Forced success"

    attr_accessor :test

    def gateway_class
      self.class
    end

    def create_profile(payment)
      return if payment.source.has_payment_profile?

      # simulate the storage of credit card profile using remote service
      if success = VALID_CCS.include?(payment.source.number)
        payment.source.update(gateway_customer_profile_id: generate_profile_id(success))
      end
    end

    def authorize(_money, credit_card, _options = {})
      profile_id = credit_card.gateway_customer_profile_id
      message_detail = " - #{__method__}"
      if VALID_CCS.include?(credit_card.number) || profile_id&.starts_with?("BGS-")
        ActiveMerchant::Billing::Response.new(true, SUCCESS_MESSAGE + message_detail, {}, test: true, authorization: AUTHORIZATION_CODE, avs_result: {code: "D"})
      else
        ActiveMerchant::Billing::Response.new(false, FAILURE_MESSAGE + message_detail, {message: FAILURE_MESSAGE + message_detail}, test: true)
      end
    end

    def purchase(_money, credit_card, _options = {})
      profile_id = credit_card.gateway_customer_profile_id
      message_detail = " - #{__method__}"
      if VALID_CCS.include?(credit_card.number) || profile_id&.starts_with?("BGS-")
        ActiveMerchant::Billing::Response.new(true, SUCCESS_MESSAGE + message_detail, {}, test: true, authorization: AUTHORIZATION_CODE, avs_result: {code: "M"})
      else
        ActiveMerchant::Billing::Response.new(false, FAILURE_MESSAGE + message_detail, message: FAILURE_MESSAGE + message_detail, test: true)
      end
    end

    def credit(_money, _credit_card, _response_code, _options = {})
      message_detail = " - #{__method__}"
      ActiveMerchant::Billing::Response.new(true, SUCCESS_MESSAGE + message_detail, {}, test: true, authorization: AUTHORIZATION_CODE)
    end

    def capture(_money, authorization, _gateway_options)
      message_detail = " - #{__method__}"
      if authorization == "12345"
        ActiveMerchant::Billing::Response.new(true, SUCCESS_MESSAGE + message_detail, {}, test: true)
      else
        ActiveMerchant::Billing::Response.new(false, FAILURE_MESSAGE + message_detail, error: FAILURE_MESSAGE + message_detail, test: true)
      end
    end

    def void(_response_code, _credit_card, options = {})
      message_detail = " - #{__method__}"
      if options[:originator].completed?
        ActiveMerchant::Billing::Response.new(false, FAILURE_MESSAGE + message_detail, {}, test: true, authorization: AUTHORIZATION_CODE)
      else
        ActiveMerchant::Billing::Response.new(true, SUCCESS_MESSAGE + message_detail, {}, test: true, authorization: AUTHORIZATION_CODE)
      end
    end

    def test?
      # Test mode is not really relevant with bogus gateway (no such thing as live server)
      true
    end

    def payment_profiles_supported?
      true
    end

    def actions
      %w[capture void credit]
    end

    private

    def generate_profile_id(success)
      record = true
      prefix = success ? "BGS" : "FAIL"
      while record
        random = "#{prefix}-#{Array.new(6) { rand(6) }.join}"
        record = Spree::CreditCard.where(gateway_customer_profile_id: random).first
      end
      random
    end
  end
end
