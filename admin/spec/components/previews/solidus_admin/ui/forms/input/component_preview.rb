# frozen_string_literal: true

# @component "ui/forms/input"
class SolidusAdmin::UI::Forms::Input::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end

  # @param error toggle
  # @param size select { choices: [s, m, l] }
  # @param value text
  # @param type select :input_types
  def input_playground(error: false, size: "m", value: "value", type: "text")
    render component("ui/forms/input").new(
      tag: :input,
      type: type.to_sym,
      error: error ? "There is an error" : nil,
      size: size.to_sym,
      value:
    )
  end

  # @param error toggle
  # @param size select { choices: [s, m, l] }
  # @param content textarea
  def textarea_playground(error: false, size: "m", content: "value")
    render component("ui/forms/input").new(
      tag: :textarea,
      size: size.to_sym,
      error: error ? "There is an error" : nil
    ).with_content(content)
  end

  private

  def input_types
    current_component::TYPES.to_a
  end
end
