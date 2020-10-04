# frozen_string_literal: true

json.(user, *user_attributes)
json.bill_address do
  if user.bill_address
    json.partial!("spree/api/addresses/address", address: user.bill_address)
  else
    json.nil!
  end
end
json.ship_address do
  if user.ship_address
    json.partial!("spree/api/addresses/address", address: user.ship_address)
  else
    json.nil!
  end
end
