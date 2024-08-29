# frozen_string_literal: true

json.call(@country, *country_attributes)
json.states(@country.states) do |state|
  json.call(state, :id, :name, :abbr, :country_id)
end
