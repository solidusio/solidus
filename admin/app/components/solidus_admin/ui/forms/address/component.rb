# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Address::Component < SolidusAdmin::BaseComponent
  def initialize(address:, name:, disabled: false)
    @address = address
    @name = name
    @disabled = disabled
  end

  def state_options
    return [] unless @address.country
    @address.country.states.map { |s| [s.name, s.id] }
  end
end
