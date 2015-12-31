object @stock_transfer
attributes *stock_transfer_attributes
node(:received_item) do
  partial('solidus/api/transfer_items/show', object: @transfer_item)
end
