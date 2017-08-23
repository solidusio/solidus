json.properties(@properties) do |property|
  json.(property, *property_attributes)
end
json.count(@properties.count)
json.current_page(@properties.current_page)
json.pages(@properties.total_pages)
