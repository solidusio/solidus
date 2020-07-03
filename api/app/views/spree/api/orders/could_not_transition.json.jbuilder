# frozen_string_literal: true

Spree::Deprecation.warn(
  'spree/api/orders/could_not_transition is deprecated.' \
  ' Please use spree/api/errors/could_not_transition'
)

json.error(I18n.t(:could_not_transition, scope: "spree.api.order"))
json.errors(@order.errors.to_hash)
