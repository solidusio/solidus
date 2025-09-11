# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Address::Fields::CountryAndState::Component < SolidusAdmin::BaseComponent
  def initialize(addressable:, form_field_name:)
    @addressable = addressable
    @form_field_name = form_field_name
  end

  private

  def state_options
    return [] unless @addressable.country

    @addressable.country.states.map { |s| [s.name, s.id] }
  end
end
