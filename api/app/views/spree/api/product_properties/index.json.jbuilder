json.product_properties(@product_properties) do |product_property|
  json.(product_property, *product_property_attributes)
end
json.count(@product_properties.count)
json.current_page(@product_properties.current_page)
json.pages(@product_properties.total_pages)
