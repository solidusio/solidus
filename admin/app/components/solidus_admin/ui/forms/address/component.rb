# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Address::Component < SolidusAdmin::BaseComponent
  def initialize(form:, disabled: false)
    @form = form
    @disabled = disabled
  end
end
