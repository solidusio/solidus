# frozen_string_literal: true

require_dependency 'spree/calculator'

module Spree
  class Calculator
    TieredFlatRate =
      ActiveSupport::Deprecation::DeprecatedConstantProxy.new(
        'Spree::Calculator::TieredFlatRate',
        'Spree::Calculator::Promotion::TieredFlatRate',
        Spree::Deprecation
      )
  end
end
