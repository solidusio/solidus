json.states_required(@country.states_required) if @country
json.states(@states) { |state| json.(state, *state_attributes) }
if @states.respond_to?(:total_pages)
  json.count(@states.count)
  json.current_page(@states.current_page)
  json.pages(@states.total_pages)
end
