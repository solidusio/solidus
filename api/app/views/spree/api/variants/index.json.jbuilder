json.count(@variants.count)
json.total_count(@variants.total_count)
json.current_page(@variants.current_page)
json.pages(@variants.total_pages)
json.variants(@variants) do |variant|
  json.partial!("spree/api/variants/big", variant: variant)
end
