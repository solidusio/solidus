# frozen_string_literal: true

json.cache! address do
  json.call(address, *address_attributes)
  json.country do
    if address.country
      json.call(address.country, *country_attributes)
    else
      json.nil!
    end
  end
  json.state do
    if address.state
      json.call(address.state, *state_attributes)
    else
      json.nil!
    end
  end
end
