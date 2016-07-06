object false
child(@orders => :orders) do
  extends "spree/api/orders/order"
end
node(:count) { @orders.count }
node(:current_page) { @orders.current_page }
node(:pages) { @orders.total_pages }
