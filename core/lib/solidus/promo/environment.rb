# frozen_string_literal: true

module Solidus
  module Promo
    Environment =
      ActiveSupport::Deprecation::DeprecatedConstantProxy.new(
        'Solidus::Promo::Environment',
        'Solidus::Core::Environment::Promotions',
        Solidus::Deprecation
      )
  end
end
