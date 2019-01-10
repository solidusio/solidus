# frozen_string_literal: true

eu_vat = Spree::Zone.find_or_create_by!(name: "EU_VAT", description: "Countries that make up the EU VAT zone.")
north_america = Spree::Zone.find_or_create_by!(name: "North America", description: "USA + Canada")

%w(PL FI PT RO DE FR SK HU SI IE AT ES IT BE SE LV BG GB LT CY LU MT DK NL EE HR CZ GR).
each do |symbol|
  eu_vat.zone_members.find_or_create_by!(zoneable: Spree::Country.find_by!(iso: symbol))
end

%w(US CA).each do |symbol|
  north_america.zone_members.find_or_create_by!(zoneable: Spree::Country.find_by!(iso: symbol))
end
