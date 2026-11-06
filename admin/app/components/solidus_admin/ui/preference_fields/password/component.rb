# frozen_string_literal: true

class SolidusAdmin::UI::PreferenceFields::Password::Component < SolidusAdmin::UI::PreferenceFields::Base::Component
  private

  def component_input_attributes = {type: :password}
end
