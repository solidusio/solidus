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
  def playground(hint: "hint", tip: "tip", error: "error")
    render component("ui/forms/field").new(hint: hint, tip: tip, error: error)
  end
end
