module Spree
  module Core
    module ControllerHelpers
      module Pricing
        extend ActiveSupport::Concern

        included do
          helper_method :current_currency
        end

        def current_currency
          current_store.try!(:default_currency).presence || Spree::Config[:currency]
        end
      end
    end
  end
end
