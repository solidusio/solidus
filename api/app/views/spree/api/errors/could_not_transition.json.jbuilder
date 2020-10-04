# frozen_string_literal: true

json.error(I18n.t(:could_not_transition, scope: "spree.api", resource: resource.class.name.demodulize.underscore))
json.errors(resource.errors.to_hash)
