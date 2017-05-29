module Spree
  # @deprecated Use Spree::PaymentMethod::SimpleBogusCreditCard instead
  class Gateway::BogusSimple
    def initialize
      Spree::Deprecation.warn \
        'Spree::Gateway::BogusSimple is deprecated. ' \
          'Please use Spree::PaymentMethod::SimpleBogusCreditCard instead'
    end
  end

  # Bogus Gateway that doesn't support payment profiles.
  class PaymentMethod::SimpleBogusCreditCard < PaymentMethod::BogusCreditCard
    def payment_profiles_supported?
      false
    end

    def authorize(_money, credit_card, _options = {})
      if VALID_CCS.include? credit_card.number
        ActiveMerchant::Billing::Response.new(true, 'Bogus Gateway: Forced success', {}, test: true, authorization: '12345', avs_result: { code: 'A' })
      else
        ActiveMerchant::Billing::Response.new(false, 'Bogus Gateway: Forced failure', { message: 'Bogus Gateway: Forced failure' }, test: true)
      end
    end

    def purchase(_money, credit_card, _options = {})
      if VALID_CCS.include? credit_card.number
        ActiveMerchant::Billing::Response.new(true, 'Bogus Gateway: Forced success', {}, test: true, authorization: '12345', avs_result: { code: 'A' })
      else
        ActiveMerchant::Billing::Response.new(false, 'Bogus Gateway: Forced failure', message: 'Bogus Gateway: Forced failure', test: true)
      end
    end
  end
end
