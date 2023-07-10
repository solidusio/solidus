# frozen_string_literal: true

# @component "ui/button"
class SolidusAdmin::UI::Button::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  # @param text text
  def overview(text: "Button")
    render_with_template locals: { text: text }
  end

  # @param size select { choices: [s, m, l] }
  # @param scheme select { choices: [primary, secondary, ghost] }
  # @param text text
  def playground(size: :m, scheme: :primary, text: "Button")
    render component("ui/button").new(size: size, scheme: scheme, text: text)
  end
end
