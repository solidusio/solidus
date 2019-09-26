# frozen_string_literal: true

require_dependency 'spree/calculator'

module Spree
  class Calculator
    FlatRate =
      ActiveSupport::Deprecation::DeprecatedConstantProxy.new(
        'Spree::Calculator::FlatRate',
        'Spree::Calculator::Promotion::FlatRate',
        Spree::Deprecation
      )
  end
end
