json.stock_locations(@stock_locations) do |stock_location|
  json.partial!("spree/api/stock_locations/stock_location", stock_location: stock_location)
end
json.count(@stock_locations.count)
json.current_page(@stock_locations.current_page)
json.pages(@stock_locations.total_pages)
