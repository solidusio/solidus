# frozen_string_literal: true

json.array! @user_addresses do |user_address|
  json.partial!("spree/api/addresses/address", address: user_address.address)

  json.default user_address.default

  # This is a bit of a hack.
  # This attribute is only shown on the update action
  if @address
    json.update_target @address == user_address.address
  end
end
