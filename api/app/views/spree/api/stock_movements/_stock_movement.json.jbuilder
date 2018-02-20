# frozen_string_literal: true

json.(stock_movement, *stock_movement_attributes)
json.stock_item do
  json.partial!("spree/api/stock_items/stock_item", stock_item: stock_movement.stock_item)
end
