collection @user_addresses
node do |user_address|
  partial("spree/api/addresses/show", object: user_address.address).merge(
    default: user_address.default,
    update_target: @address == user_address.address,
  )
end
