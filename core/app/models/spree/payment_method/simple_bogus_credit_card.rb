# frozen_string_literal: true

module Spree
  # Bogus Gateway that doesn't support payment profiles.
  class PaymentMethod::SimpleBogusCreditCard < PaymentMethod::BogusCreditCard
    def payment_profiles_supported?
      false
    end

    def authorize(_money, credit_card, _options = {})
      message_detail = " - #{__method__}"

      if VALID_CCS.include? credit_card.number
        ActiveMerchant::Billing::Response.new(true, SUCCESS_MESSAGE + message_detail, {}, test: true, authorization: AUTHORIZATION_CODE, avs_result: {code: "A"})
      else
        ActiveMerchant::Billing::Response.new(false, FAILURE_MESSAGE + message_detail, {message: FAILURE_MESSAGE}, test: true)
      end
    end

    def purchase(_money, credit_card, _options = {})
      message_detail = " - #{__method__}"

      if VALID_CCS.include? credit_card.number
        ActiveMerchant::Billing::Response.new(true, SUCCESS_MESSAGE + message_detail, {}, test: true, authorization: AUTHORIZATION_CODE, avs_result: {code: "A"})
      else
        ActiveMerchant::Billing::Response.new(false, FAILURE_MESSAGE + message_detail, message: FAILURE_MESSAGE, test: true)
      end
    end

    def void(_response_code, options = {})
      message_detail = " - #{__method__}"

      if options[:originator].completed?
        ActiveMerchant::Billing::Response.new(false, FAILURE_MESSAGE + message_detail, {}, test: true, authorization: AUTHORIZATION_CODE)
      else
        ActiveMerchant::Billing::Response.new(true, SUCCESS_MESSAGE + message_detail, {}, test: true, authorization: AUTHORIZATION_CODE)
      end
    end
  end
end
