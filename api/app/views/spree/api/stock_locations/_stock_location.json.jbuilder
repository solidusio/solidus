# frozen_string_literal: true

json.call(stock_location, *stock_location_attributes)
json.country do
  if stock_location.country
    json.call(stock_location.country, *country_attributes)
  else
    json.nil!
  end
end
json.state do
  if stock_location.state
    json.call(stock_location.state, *state_attributes)
  else
    json.nil!
  end
end
