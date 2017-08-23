json.stock_movements(@stock_movements) do |stock_movement|
  json.partial!("spree/api/stock_movements/stock_movement", stock_movement: stock_movement)
end
json.count(@stock_movements.count)
json.current_page(@stock_movements.current_page)
json.pages(@stock_movements.total_pages)
