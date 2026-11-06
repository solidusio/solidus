# frozen_string_literal: true

class SolidusAdmin::UI::PreferenceFields::Decimal::Component < SolidusAdmin::UI::PreferenceFields::Base::Component
  private

  def component_input_attributes = {step: :any, type: :number}
end
