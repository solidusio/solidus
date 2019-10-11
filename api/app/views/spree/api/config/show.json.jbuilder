# frozen_string_literal: true

json.default_country_id(Solidus::Country.default.id)
json.default_country_iso(Solidus::Config[:default_country_iso])
