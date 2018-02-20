# frozen_string_literal: true

json.partial! 'spree/api/shared/pagination', pagination: @shipments
json.shipments(@shipments) do |shipment|
  json.partial!("spree/api/shipments/big", shipment: shipment)
end
