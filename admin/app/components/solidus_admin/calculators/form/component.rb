# frozen_string_literal: true

class SolidusAdmin::Calculators::Form::Component < SolidusAdmin::BaseComponent
  def initialize(form:, calculators:)
    @form = form
    @calculators = calculators
  end

  def field_for(preference_name, current_value, calculator)
    field_type = calculator.preference_type(preference_name)

    component("ui/preference_fields/#{field_type}").new(
      type: params.dig(:shipping_method, :calculator_type) || calculator.type,
      name: "shipping_method[calculator_attributes][preferred_#{preference_name}]",
      preference_name:,
      value: (
        (field_type == :boolean) ? current_value&.to_s&.presence : current_value
      ) || calculator.preference_default(preference_name)
    )
  end
end
