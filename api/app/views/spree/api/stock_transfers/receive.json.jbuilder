json.(@stock_transfer, *stock_transfer_attributes)
json.received_item do
  json.partial!("spree/api/transfer_items/transfer_item", transfer_item: @transfer_item)
end
