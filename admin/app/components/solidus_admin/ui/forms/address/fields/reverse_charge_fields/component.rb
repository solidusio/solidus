# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Address::Fields::ReverseChargeFields::Component < SolidusAdmin::BaseComponent
  def initialize(addressable:, form_field_name:)
    @addressable = addressable
    @form_field_name = form_field_name
  end

  def render?
    Spree::Backend::Config.show_reverse_charge_fields
  end
end
