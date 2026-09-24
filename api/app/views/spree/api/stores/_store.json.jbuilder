# frozen_string_literal: true

json.call(store, *store_attributes)
json.address do
  if store.address
    json.partial!("spree/api/addresses/address", address: store.address)
  else
    json.nil!
  end
end
