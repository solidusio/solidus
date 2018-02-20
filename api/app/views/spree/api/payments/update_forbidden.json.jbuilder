# frozen_string_literal: true

json.error(I18n.t(:update_forbidden, state: @payment.state, scope: "spree.api.payment"))
