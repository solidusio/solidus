object false
child(@stock_locations => :stock_locations) do
  extends 'spree/api/stock_locations/show'
end
node(:count) { @stock_locations.count }
node(:current_page) { @stock_locations.current_page }
node(:pages) { @stock_locations.total_pages }
