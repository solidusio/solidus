# frozen_string_literal: true

require_dependency 'spree/calculator'

module Spree
  class Calculator
    FlexiRate =
      ActiveSupport::Deprecation::DeprecatedConstantProxy.new(
        'Spree::Calculator::FlexiRate',
        'Spree::Calculator::Promotion::FlexiRate',
        Spree::Deprecation
      )
  end
end
