# frozen_string_literal: true

json.error(I18n.t(:credit_over_limit, limit: @payment.credit_allowed, scope: "spree.api.payment"))
