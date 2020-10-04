# frozen_string_literal: true

json.(@country, *country_attributes)
json.states(@country.states) do |state|
  json.(state, :id, :name, :abbr, :country_id)
end
