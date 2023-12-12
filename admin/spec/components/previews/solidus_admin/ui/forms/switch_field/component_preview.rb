# frozen_string_literal: true

# @component "ui/forms/switch_field"
class SolidusAdmin::UI::Forms::SwitchField::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end

  # @param label text
  # @param error text
  # @param hint text
  # @param tip text
  # @param size select { choices: [s, m] }
  # @param checked toggle
  # @param disabled toggle
  def playground(
    label: "Your Label",
    error: "Your Error Message",
    hint: "Your Hint Text",
    tip: "Your Tip Text",
    size: :m,
    checked: false,
    disabled: false
  )
    render current_component.new(
      label: label,
      name: nil,
      error: [error],
      hint: hint,
      tip: tip,
      size: size.to_sym,
      checked: checked,
      disabled: disabled,
    )
  end
end
