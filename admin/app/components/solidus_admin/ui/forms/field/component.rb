# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Field::Component < SolidusAdmin::BaseComponent
  def initialize(label:, hint: nil, tip: nil, error: nil, **attributes)
    @label = label
    @hint = hint
    @tip = tip
    @error = error
    @attributes = attributes
  end
end
