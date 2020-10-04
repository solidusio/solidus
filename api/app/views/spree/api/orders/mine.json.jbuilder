# frozen_string_literal: true

json.orders(@orders) do |order|
  json.partial!("spree/api/orders/big", order: order)
end
json.partial! 'spree/api/shared/pagination', pagination: @orders
