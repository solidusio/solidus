# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Address::Component < SolidusAdmin::BaseComponent
  def initialize(addressable:, fieldset_name:, disabled: false)
    @addressable = addressable
    @fieldset_name = fieldset_name
    @disabled = disabled
  end

  def state_options
    return [] unless @addressable.country
    @addressable.country.states.map { |s| [s.name, s.id] }
  end
end
