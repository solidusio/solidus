# frozen_string_literal: true

json.call(stock_location, *stock_location_attributes)
json.country do
  if stock_location.country
    json.call(stock_location.country, *country_attributes)
  else
    json.nil!
  end
end
json.principal_subdivision do
  if stock_location.principal_subdivision
    json.call(stock_location.principal_subdivision, *state_attributes)
  else
    json.nil!
  end
end

# Deprecated aliases of the principal_subdivision keys above. Sourced from the
# new readers so that serialisation does not emit deprecation warnings.
json.state_id stock_location.principal_subdivision_id
json.state_name stock_location.principal_subdivision_name
json.state do
  if stock_location.principal_subdivision
    json.call(stock_location.principal_subdivision, *state_attributes)
  else
    json.nil!
  end
end
