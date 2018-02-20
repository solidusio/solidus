# frozen_string_literal: true

json.array!(@users) do |user|
  json.id user.id
  json.email user.email

  address_fields = [:firstname, :lastname, :address1, :address2, :city, :zipcode, :phone, :state_name, :state_id, :country_id, :company]
  json.ship_address do
    if user.ship_address
      json.(user.ship_address, *address_fields)
      if user.ship_address.state
        json.state do
          json.name user.ship_address.state.name
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
      json.(user.bill_address, *address_fields)
      if user.bill_address.state
        json.state do
          json.name user.bill_address.state.name
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
