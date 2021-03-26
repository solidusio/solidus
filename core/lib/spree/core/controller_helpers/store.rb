# frozen_string_literal: true

module Spree
  module Core
    module ControllerHelpers
      module Store
        extend ActiveSupport::Concern

        included do
          helper_method :current_store,
                        :available_currencies,
                        :supported_currencies,
                        :multicurrency?
          delegate :supported_currencies,
                   :multicurrency?, to: :current_store
        end

        def current_store
          @current_store ||= Spree::Config.current_store_selector_class.new(request).store
        end

        # Array of iso codes for all available currencies
        #
        # @return [Array<String>]
        # @example
        #   ['USD', 'EUR']
        def available_currencies
          Spree::Config.available_currencies.map(&:iso_code)
        end
      end
    end
  end
end
