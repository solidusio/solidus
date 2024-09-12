# frozen_string_literal: true

# @component "ui/forms/field"
class SolidusAdmin::UI::Forms::Field::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end

  # @param hint text
  # @param tip text
  # @param error text
  def playground(label: "My field", hint: "hint", tip: "tip", error: "error")
    render component("ui/forms/field").new(label:, hint:, tip:, error:, input_attributes: {
      tag: :input, value: "My value", error:
    })
  end
end
