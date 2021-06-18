# frozen_string_literal: true

module Spree
  module Core
    module ControllerHelpers
      module Pricing
        extend ActiveSupport::Concern

        included do
          # Key where the current currency should be stored in a requests' session
          CURRENCY_SESSION_KEY = 'currency'

          helper_method :current_pricing_options,
                        :current_currency,
                        :switch_currency
        end

        # @see Variant::PricingOptions#from_context
        def current_pricing_options
          Spree::Config.pricing_options_class.from_context(self)
        end

        # Current currency from {#current_pricing_options}
        #
        # @return [String]
        # @see #current_pricing_options
        # @example
        #   'USD'
        def current_currency
          current_pricing_options.currency
        end

        # Currency stored in the session
        #
        # @return [String, nil]
        # @see CURRENCY_SESSION_KEY
        # @example
        #   'USD'
        def currency_in_session
          session[CURRENCY_SESSION_KEY]
        end

        # Stores given currency in the session
        #
        # @param currency [String]
        # @see #currency_in_session
        def switch_currency(currency)
          session[CURRENCY_SESSION_KEY] = currency
        end
      end
    end
  end
end
