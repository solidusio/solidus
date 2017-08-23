json.count(@products.size)
json.total_count(@products.total_count)
json.current_page(@products.current_page)
json.per_page(@products.limit_value)
json.pages(@products.total_pages)
json.products(@products) do |product|
  json.partial!("spree/api/products/product", product: product)
end
