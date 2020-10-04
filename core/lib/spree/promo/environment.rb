# frozen_string_literal: true

module Spree
  module Promo
    Environment =
      ActiveSupport::Deprecation::DeprecatedConstantProxy.new(
        'Spree::Promo::Environment',
        'Spree::Core::Environment::Promotions',
        Spree::Deprecation
      )
  end
end
