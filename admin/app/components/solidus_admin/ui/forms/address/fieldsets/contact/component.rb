# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Address::Fieldsets::Contact::Component < SolidusAdmin::UI::Forms::Address::Fieldsets::Base
  def fields_map
    {
      name: -> { component("ui/forms/field").text_field(@form_field_name, :name, object: @addressable) },
      street: -> { component("ui/forms/field").text_field(@form_field_name, :address1, object: @addressable) },
      street_contd: -> { component("ui/forms/field").text_field(@form_field_name, :address2, object: @addressable) },
      city_and_zipcode: -> { component("ui/forms/address/fields/city_and_zipcode").new(form_field_name: @form_field_name, addressable: @addressable) },
      country_and_state: -> { component("ui/forms/address/fields/country_and_state").new(form_field_name: @form_field_name, addressable: @addressable) },
      phone: -> { component("ui/forms/field").text_field(@form_field_name, :phone, object: @addressable) },
      email: -> { component("ui/forms/field").text_field(@form_field_name, :email, object: @addressable) },
      reverse_charge: -> { component("ui/forms/address/fields/reverse_charge_fields").new(form_field_name: @form_field_name, addressable: @addressable) }
    }
  end
end
