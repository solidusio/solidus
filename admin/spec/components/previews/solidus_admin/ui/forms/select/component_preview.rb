# frozen_string_literal: true

# @component "ui/forms/select"
class SolidusAdmin::UI::Forms::Select::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end

  # @param size select { choices: [s, m, l] }
  # @param options number
  # @param multiple toggle
  # @param selected toggle
  # @param disabled toggle
  # @param error toggle
  # @param include_blank toggle
  # @param placeholder text
  # @param hint text
  # @param tip text
  def playground(size: "m", options: 3, multiple: false, selected: false, disabled: false, error: false, include_blank: true, placeholder: nil, hint: nil, tip: nil)
    options = (1..options).map { |i| ["Option #{i}", i] }
    options.unshift(["None", ""]) if include_blank

    render component("ui/forms/select").new(
      label: "Label",
      name: "select",
      hint:,
      tip:,
      error: error ? "There is an error" : nil,
      size: size.to_sym,
      choices: options,
      value: (multiple && [1, 2] || 1 if selected),
      multiple:,
      disabled:,
      placeholder:
    )
  end
end
