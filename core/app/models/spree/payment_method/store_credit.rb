# frozen_string_literal: true

module Spree
  class PaymentMethod::StoreCredit < PaymentMethod
    def payment_source_class
      ::Spree::StoreCredit
    end

    def authorize(amount_in_cents, provided_store_credit, gateway_options = {})
      if provided_store_credit.nil?
        ActiveMerchant::Billing::Response.new(false, I18n.t('spree.store_credit.unable_to_find'), {}, {})
      else
        action = ->(store_credit) {
          store_credit.authorize(
            amount_in_cents / 100.0.to_d,
            gateway_options[:currency],
            action_originator: gateway_options[:originator]
          )
        }
        handle_action_call(provided_store_credit, action, :authorize)
      end
    end

    def capture(amount_in_cents, auth_code, gateway_options = {})
      action = ->(store_credit) {
        store_credit.capture(
          amount_in_cents / 100.0.to_d,
          auth_code,
          gateway_options[:currency],
          action_originator: gateway_options[:originator]
        )
      }

      handle_action(action, :capture, auth_code)
    end

    def purchase(amount_in_cents, store_credit, gateway_options = {})
      eligible_events = store_credit.store_credit_events.where(amount: amount_in_cents / 100.0.to_d, action: Spree::StoreCredit::ELIGIBLE_ACTION)
      event = eligible_events.find do |eligible_event|
        store_credit.store_credit_events.where(authorization_code: eligible_event.authorization_code)
                                        .where.not(action: Spree::StoreCredit::ELIGIBLE_ACTION).empty?
      end

      if event.blank?
        ActiveMerchant::Billing::Response.new(false, I18n.t('spree.store_credit.unable_to_find'), {}, {})
      else
        capture(amount_in_cents, event.authorization_code, gateway_options)
      end
    end

    def void(auth_code, gateway_options = {})
      action = ->(store_credit) {
        store_credit.void(auth_code, action_originator: gateway_options[:originator])
      }
      handle_action(action, :void, auth_code)
    end

    def credit(amount_in_cents, auth_code, gateway_options = {})
      action = ->(store_credit) do
        currency = gateway_options[:currency] || store_credit.currency
        originator = gateway_options[:originator]

        store_credit.credit(amount_in_cents / 100.0.to_d, auth_code, currency, action_originator: originator)
      end

      handle_action(action, :credit, auth_code)
    end

    # @see Spree::PaymentMethod#try_void
    def try_void(payment)
      auth_code = payment.response_code
      store_credit_event = auth_or_capture_event(auth_code)
      store_credit = store_credit_event.try(:store_credit)

      if store_credit_event.nil? || store_credit.nil?
        ActiveMerchant::Billing::Response.new(false, '', {}, {})
      elsif store_credit_event.capture_action?
        false # payment#cancel! handles the refund
      elsif store_credit_event.authorization_action?
        void(auth_code)
      else
        ActiveMerchant::Billing::Response.new(false, '', {}, {})
      end
    end

    def source_required?
      true
    end

    private

    def handle_action_call(store_credit, action, action_name, auth_code = nil)
      store_credit.with_lock do
        if response = action.call(store_credit)
          # note that we only need to return the auth code on an 'auth', but it's innocuous to always return
          ActiveMerchant::Billing::Response.new(true,
                                                I18n.t('spree.store_credit.successful_action', action: action_name),
                                                {}, { authorization: auth_code || response })
        else
          ActiveMerchant::Billing::Response.new(false, store_credit.errors.full_messages.join, {}, {})
        end
      end
    end

    def handle_action(action, action_name, auth_code)
      # Find first event with provided auth_code
      store_credit = Spree::StoreCreditEvent.find_by(authorization_code: auth_code).try(:store_credit)

      if store_credit.nil?
        ActiveMerchant::Billing::Response.new(false, I18n.t('spree.store_credit.unable_to_find_for_action', auth_code: auth_code, action: action_name), {}, {})
      else
        handle_action_call(store_credit, action, action_name, auth_code)
      end
    end

    def auth_or_capture_event(auth_code)
      capture_event = Spree::StoreCreditEvent.find_by(authorization_code: auth_code, action: Spree::StoreCredit::CAPTURE_ACTION)
      auth_event = Spree::StoreCreditEvent.find_by(authorization_code: auth_code, action: Spree::StoreCredit::AUTHORIZE_ACTION)
      capture_event || auth_event
    end
  end
end
