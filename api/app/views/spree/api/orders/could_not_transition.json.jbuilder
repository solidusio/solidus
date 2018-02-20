# frozen_string_literal: true

json.error(I18n.t(:could_not_transition, scope: "spree.api.order"))
json.errors(@order.errors.to_hash)
