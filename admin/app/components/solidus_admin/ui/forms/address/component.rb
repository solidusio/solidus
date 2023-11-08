# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Address::Component < SolidusAdmin::BaseComponent
  def initialize(form:, disabled: false)
    @form = form
    @disabled = disabled
  end

  def state_options
    return [] unless @form.object.country
    @form.object.country.states.map { |s| [s.name, s.id] }
  end
end
