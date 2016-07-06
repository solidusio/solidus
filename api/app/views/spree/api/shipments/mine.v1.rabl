object false

node(:count) { @shipments.count }
node(:current_page) { @shipments.current_page }
node(:pages) { @shipments.total_pages }

child(@shipments => :shipments) do
  extends "spree/api/shipments/big"
end
