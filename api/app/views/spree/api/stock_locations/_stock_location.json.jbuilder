json.(stock_location, *stock_location_attributes)
if stock_location.country
  json.country { json.(stock_location.country, *country_attributes) }
end
if stock_location.state
  json.state { json.(stock_location.state, *state_attributes) }
end
