module Spree::PromotionHandler
  FreeShipping = ActiveSupport::Deprecation::DeprecatedConstantProxy.new(
    'Spree::PromotionHandler::FreeShipping',
    'Spree::PromotionHandler::Shipping',
    Spree::Deprecation,
  )
end
