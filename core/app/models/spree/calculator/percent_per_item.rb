# frozen_string_literal: true

require_dependency 'spree/calculator'

module Spree
  class Calculator
    PercentPerItem =
      ActiveSupport::Deprecation::DeprecatedConstantProxy.new(
        'Spree::Calculator::PercentPerItem',
        'Spree::Calculator::Promotion::PercentPerItem',
        Spree::Deprecation
      )
  end
end
