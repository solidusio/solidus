# frozen_string_literal: true

require_dependency 'spree/calculator'

module Spree
  class Calculator
    PriceSack =
      ActiveSupport::Deprecation::DeprecatedConstantProxy.new(
        'Spree::Calculator::PriceSack',
        'Spree::Calculator::Promotion::PriceSack',
        Spree::Deprecation
      )
  end
end
