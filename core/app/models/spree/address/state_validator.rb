# frozen_string_literal: true

# @deprecated Use Spree::Address::PrincipalSubdivisionValidator instead.
Spree::Address::StateValidator = ActiveSupport::Deprecation::DeprecatedConstantProxy.new(
  "Spree::Address::StateValidator",
  "Spree::Address::PrincipalSubdivisionValidator",
  Spree.deprecator
)
