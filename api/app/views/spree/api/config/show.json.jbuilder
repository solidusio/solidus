# frozen_string_literal: true

json.default_country_id(Spree::Country.default.id)
json.default_country_iso(Spree::Config[:default_country_iso])
