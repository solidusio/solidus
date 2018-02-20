# frozen_string_literal: true

json.cache! address do
  json.(address, *address_attributes)
  json.country do
    if address.country
      json.(address.country, *country_attributes)
    else
      json.nil!
    end
  end
  json.state do
    if address.state
      json.(address.state, *state_attributes)
    else
      json.nil!
    end
  end
end
