# frozen_string_literal: true

module Solidus::PromotionHandler
  FreeShipping = ActiveSupport::Deprecation::DeprecatedConstantProxy.new(
    'Solidus::PromotionHandler::FreeShipping',
    'Solidus::PromotionHandler::Shipping',
    Solidus::Deprecation,
  )
end
