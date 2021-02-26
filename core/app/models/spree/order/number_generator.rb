# frozen_string_literal: true

module Spree
  # [Deprecated] Generates order numbers
  #
  # This class is deprecated and will proxy to Spree::Core::NumberGenerator, use it instead.
  # set your own instance of this class in your stores configuration with different options:
  #
  # Example:
  #   Spree::Core::NumberGenerator.new(
  #     prefix: 'B',
  #     lenght: 8,
  #     letters: false,
  #     model: Spree::Order
  #   )
  #
  #

  Order::NumberGenerator = ActiveSupport::Deprecation::DeprecatedConstantProxy
    .new('Spree::Order::NumberGenerator', 'Spree::Core::NumberGenerator', Spree::Deprecation)
end
