# frozen_string_literal: true

json.error(I18n.t(:invalid_resource, scope: "spree.api"))
json.errors(@resource.errors.to_hash)
