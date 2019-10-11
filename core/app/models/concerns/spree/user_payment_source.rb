# frozen_string_literal: true

module Solidus
  module UserPaymentSource
    extend ActiveSupport::Concern

    def default_credit_card
      Solidus::Deprecation.warn(
        "user.default_credit_card is deprecated. Please use user.wallet.default_wallet_payment_source instead.",
        caller
      )
      default = wallet.default_wallet_payment_source
      if default && default.payment_source.is_a?(Solidus::CreditCard)
        default.payment_source
      end
    end

    def payment_sources
      Solidus::Deprecation.warn(
        "user.payment_sources is deprecated. Please use user.wallet.wallet_payment_sources instead.",
        caller
      )
      credit_cards.with_payment_profile
    end
  end
end
