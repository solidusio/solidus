# frozen_string_literal: true

require 'solidus/deprecation'

module Solidus
  module Core
    module ControllerHelpers
      module Pricing
        extend ActiveSupport::Concern

        included do
          helper_method :current_currency
          helper_method :current_pricing_options
        end

        def current_pricing_options
          Solidus::Config.pricing_options_class.from_context(self)
        end

        def current_currency
          current_pricing_options.currency
        end
        deprecate current_currency: :current_pricing_options, deprecator: Solidus::Deprecation
      end
    end
  end
end
