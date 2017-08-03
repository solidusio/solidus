json.stock_items(@stock_items) do |stock_item|
  json.partial!("spree/api/stock_items/stock_item", stock_item: stock_item)
end
json.count(@stock_items.count)
json.current_page(@stock_items.current_page)
json.pages(@stock_items.total_pages)
