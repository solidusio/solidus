# frozen_string_literal: true

json.array!(@users) do |user|
  json.id user.id
  json.email user.email

  address_fields = [
    :name,
    :address1,
    :address2,
    :city,
    :zipcode,
    :phone,
    :principal_subdivision_name,
    :principal_subdivision_id,
    :country_id,
    :company,
    :email,
    :vat_id,
    :reverse_charge_status
  ]
  json.ship_address do
    if user.ship_address
      json.call(user.ship_address, *address_fields)
      json.state_name user.ship_address.principal_subdivision_name
      json.state_id user.ship_address.principal_subdivision_id
      if user.ship_address.principal_subdivision
        json.principal_subdivision do
          json.name user.ship_address.principal_subdivision.name
        end
        json.state do
          json.name user.ship_address.principal_subdivision.name
        end
      end
      if user.ship_address.country
        json.country do
          json.name user.ship_address.country.name
        end
      end
    end
  end

  json.bill_address do
    if user.bill_address
      json.call(user.bill_address, *address_fields)
      json.state_name user.bill_address.principal_subdivision_name
      json.state_id user.bill_address.principal_subdivision_id
      if user.bill_address.principal_subdivision
        json.principal_subdivision do
          json.name user.bill_address.principal_subdivision.name
        end
        json.state do
          json.name user.bill_address.principal_subdivision.name
        end
      end
      if user.bill_address.country
        json.country do
          json.name user.bill_address.country.name
        end
      end
    end
  end
end
