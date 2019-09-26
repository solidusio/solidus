# frozen_string_literal: true

require_dependency 'spree/calculator'

module Spree
  class Calculator
    FlatPercentItemTotal =
      ActiveSupport::Deprecation::DeprecatedConstantProxy.new(
        'Spree::Calculator::FlatPercentItemTotal',
        'Spree::Calculator::Promotion::FlatPercentItemTotal',
        Spree::Deprecation
      )
  end
end
