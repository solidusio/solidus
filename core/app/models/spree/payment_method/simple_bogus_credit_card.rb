# frozen_string_literal: true

module Spree
  # Bogus Gateway that doesn't support payment profiles.
  class PaymentMethod::SimpleBogusCreditCard < PaymentMethod::BogusCreditCard
    def payment_profiles_supported?
      false
    end

    def authorize(_money, credit_card, _options = {})
      if VALID_CCS.include? credit_card.number
        ActiveMerchant::Billing::Response.new(true, SUCCESS_MESSAGE, {}, test: true, authorization: AUTHORIZATION_CODE, avs_result: { code: 'A' })
      else
        ActiveMerchant::Billing::Response.new(false, FAILURE_MESSAGE, { message: FAILURE_MESSAGE }, test: true)
      end
    end

    def purchase(_money, credit_card, _options = {})
      if VALID_CCS.include? credit_card.number
        ActiveMerchant::Billing::Response.new(true, SUCCESS_MESSAGE, {}, test: true, authorization: AUTHORIZATION_CODE, avs_result: { code: 'A' })
      else
        ActiveMerchant::Billing::Response.new(false, FAILURE_MESSAGE, message: FAILURE_MESSAGE, test: true)
      end
    end
  end
end

