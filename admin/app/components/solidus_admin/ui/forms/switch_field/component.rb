# frozen_string_literal: true

class SolidusAdmin::UI::Forms::SwitchField::Component < SolidusAdmin::BaseComponent
  def initialize(label:, error:, hint: nil, tip: nil, **attributes)
    @label = label
    @error = error
    @hint = hint
    @tip = tip
    @attributes = attributes
  end
end
