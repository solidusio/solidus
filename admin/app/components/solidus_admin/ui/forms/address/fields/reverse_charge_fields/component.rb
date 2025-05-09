# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Address::Fields::ReverseChargeFields::Component < SolidusAdmin::BaseComponent
  def initialize(addressable:, form_field_name:)
    @addressable = addressable
    @form_field_name = form_field_name
  end
end
