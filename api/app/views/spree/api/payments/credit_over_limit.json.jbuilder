# frozen_string_literal: true

json.error(I18n.t('spree.api.payment.credit_over_limit', limit: @payment.credit_allowed))
