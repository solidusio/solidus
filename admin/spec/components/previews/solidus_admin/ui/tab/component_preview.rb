# frozen_string_literal: true

# @component "ui/tab"
class SolidusAdmin::UI::Tab::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  # @param text text
  def overview(text: "text")
    render_with_template locals: { text: text }
  end

  # @param text text
  # @param size select { choices: [s, m, l] }
  # @param active toggle
  # @param disabled toggle
  def playground(text: "Tab", size: :m, active: false, disabled: false)
    render current_component.new(text: text, size: size, active: active, disabled: disabled)
  end
end
