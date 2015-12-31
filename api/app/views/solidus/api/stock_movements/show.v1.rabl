object @stock_movement
attributes *stock_movement_attributes
child :stock_item do
  extends "solidus/api/stock_items/show"
end
