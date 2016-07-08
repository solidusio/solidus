object false
child(@stock_items => :stock_items) do
  extends 'spree/api/stock_items/show'
end
node(:count) { @stock_items.count }
node(:current_page) { @stock_items.current_page }
node(:pages) { @stock_items.total_pages }
