json.orders(@orders) do |order|
  json.partial!("spree/api/orders/big", order: order)
end
json.count(@orders.count)
json.current_page(@orders.current_page)
json.pages(@orders.total_pages)
