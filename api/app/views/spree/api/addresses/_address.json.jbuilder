if address
  json.(address, *address_attributes)
  if address.country
    json.country { json.(address.country, *country_attributes) }
  end
  if address.state
    json.state { json.(address.state, *state_attributes) }
  end
end
