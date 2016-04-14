module Spree
  module Core
    module ControllerHelpers
      module Pricing
        extend ActiveSupport::Concern

        included do
          helper_method :current_currency
          helper_method :current_pricing_options
        end

        def current_pricing_options
          Spree::Config.pricing_options_class.new(
            currency: current_store.try!(:default_currency).presence || Spree::Config[:currency]
          )
        end

        def current_currency
          current_store.try!(:default_currency).presence || Spree::Config[:currency]
        end
      end
    end
  end
end
