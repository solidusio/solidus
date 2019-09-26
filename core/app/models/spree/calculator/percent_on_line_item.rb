# frozen_string_literal: true

require_dependency 'spree/calculator'

module Spree
  class Calculator
    PercentOnLineItem =
      ActiveSupport::Deprecation::DeprecatedConstantProxy.new(
        'Spree::Calculator::PercentOnLineItem',
        'Spree::Calculator::Promotion::PercentOnLineItem',
        Spree::Deprecation
      )
  end
end
