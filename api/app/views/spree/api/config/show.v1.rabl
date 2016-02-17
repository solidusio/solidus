object false
node(:default_country_id) { Spree::Country.default.id }
node(:default_country_iso) { Spree::Config[:default_country_iso] }
