object @stock_transfer
attributes *stock_transfer_attributes
child :transfer_items => :transfer_items do
  extends "spree/api/transfer_items/show"
end
