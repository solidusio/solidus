# frozen_string_literal: true

json.stock_locations(@stock_locations) do |stock_location|
  json.partial!("spree/api/stock_locations/stock_location", stock_location: stock_location)
end
json.partial! 'spree/api/shared/pagination', pagination: @stock_locations
