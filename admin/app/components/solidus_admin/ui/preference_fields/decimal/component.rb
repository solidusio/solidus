# frozen_string_literal: true

class SolidusAdmin::UI::PreferenceFields::Decimal::Component < SolidusAdmin::UI::PreferenceFields::Base::Component
  private

  def component_input_attributes = {step: 0.1, type: :number}
end
