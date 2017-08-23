json.count(@shipments.count)
json.current_page(@shipments.current_page)
json.pages(@shipments.total_pages)
json.shipments(@shipments) do |shipment|
  json.partial!("spree/api/shipments/big", shipment: shipment)
end
