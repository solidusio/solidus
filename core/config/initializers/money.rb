# frozen_string_literal: true

require 'money'

Money.locale_backend = :i18n
Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN
Money.default_currency = Money::Currency.new(Spree::Config.currency)
