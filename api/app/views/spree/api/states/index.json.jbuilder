# frozen_string_literal: true

json.states_required(@country.states_required) if @country
json.states(@states) { |state| json.(state, *state_attributes) }
if @states.respond_to?(:total_pages)
  json.partial! 'spree/api/shared/pagination', pagination: @states
end
