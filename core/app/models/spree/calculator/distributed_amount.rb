# frozen_string_literal: true

require_dependency 'spree/calculator'

module Spree
  class Calculator
    DistributedAmount =
      ActiveSupport::Deprecation::DeprecatedConstantProxy.new(
        'Spree::Calculator::DistributedAmount',
        'Spree::Calculator::Promotion::DistributedAmount',
        Spree::Deprecation
      )
  end
end
