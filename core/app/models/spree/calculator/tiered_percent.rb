# frozen_string_literal: true

require_dependency 'spree/calculator'

module Spree
  class Calculator
    TieredPercent =
      ActiveSupport::Deprecation::DeprecatedConstantProxy.new(
        'Spree::Calculator::TieredPercent',
        'Spree::Calculator::Promotion::TieredPercent',
        Spree::Deprecation
      )
  end
end
