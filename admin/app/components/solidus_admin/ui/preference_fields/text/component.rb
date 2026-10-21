# frozen_string_literal: true

class SolidusAdmin::UI::PreferenceFields::Text::Component < SolidusAdmin::UI::PreferenceFields::Base::Component
  private

  def component_input_attributes = {tag: :textarea}
end
