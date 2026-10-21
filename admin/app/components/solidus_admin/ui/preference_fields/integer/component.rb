# frozen_string_literal: true

class SolidusAdmin::UI::PreferenceFields::Integer::Component < SolidusAdmin::UI::PreferenceFields::Base::Component
  private

  def component_input_attributes = {type: :number}
end
