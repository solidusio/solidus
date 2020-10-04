# frozen_string_literal: true

json.stock_items(@stock_items) do |stock_item|
  json.partial!("spree/api/stock_items/stock_item", stock_item: stock_item)
end
json.partial! 'spree/api/shared/pagination', pagination: @stock_items
