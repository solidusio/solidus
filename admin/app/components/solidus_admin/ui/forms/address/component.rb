# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Address::Component < SolidusAdmin::BaseComponent
  def initialize(addressable:, form_field_name:, disabled: false, include_name_field: true)
    @addressable = addressable
    @form_field_name = form_field_name
    @disabled = disabled
    @include_name_field = include_name_field
  end

  def state_options
    return [] unless @addressable.country
    @addressable.country.states.map { |s| [s.name, s.id] }
  end
end
