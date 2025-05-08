# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Address::Fieldsets::ContactInfo::Component < SolidusAdmin::UI::Forms::Address::Fieldsets::Base
  def fields_map
    {
      phone: -> { component("ui/forms/field").text_field(@form_field_name, :phone, object: @addressable) },
      email: -> { component("ui/forms/field").text_field(@form_field_name, :email, object: @addressable) },
    }
  end
end
