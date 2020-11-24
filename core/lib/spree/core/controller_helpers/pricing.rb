# frozen_string_literal: true

require 'spree/deprecation'

module Spree
  module Core
    module ControllerHelpers
      module Pricing
        extend ActiveSupport::Concern

        included do
          helper_method :current_pricing_options
        end

        def current_pricing_options
          Spree::Config.pricing_options_class.from_context(self)
        end
      end
    end
  end
end
