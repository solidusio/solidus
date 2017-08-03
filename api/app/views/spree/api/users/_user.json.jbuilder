json.(user, *user_attributes)
json.bill_address do
  json.partial!("spree/api/addresses/address", address: user.bill_address)
end
json.ship_address do
  json.partial!("spree/api/addresses/address", address: user.ship_address)
end
