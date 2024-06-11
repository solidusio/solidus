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
  # @param current toggle
  # @param disabled toggle
  def playground(text: "Tab", size: :m, current: false, disabled: false)
    render current_component.new(text: text, size: size, current: current, disabled: disabled)
  end
end
