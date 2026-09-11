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
  json.principal_subdivision do
    if address.principal_subdivision
      json.call(address.principal_subdivision, *state_attributes)
    else
      json.nil!
    end
  end

  # Deprecated aliases of the principal_subdivision keys above. Sourced from the
  # new readers so that serialisation does not emit deprecation warnings.
  json.state_id address.principal_subdivision_id
  json.state_name address.principal_subdivision_name
  json.state_text address.principal_subdivision_text
  json.state do
    if address.principal_subdivision
      json.call(address.principal_subdivision, *state_attributes)
    else
      json.nil!
    end
  end
end
