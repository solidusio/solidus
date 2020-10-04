# frozen_string_literal: true

json.stock_movements(@stock_movements) do |stock_movement|
  json.partial!("spree/api/stock_movements/stock_movement", stock_movement: stock_movement)
end
json.partial! 'spree/api/shared/pagination', pagination: @stock_movements
