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
      value: value,
    )
  end

  # @param error toggle
  # @param size select { choices: [s, m, l] }
  # @param multiple toggle
  # @param rows number
  # @param options number
  # @param include_blank toggle
  def select_playground(error: false, include_blank: true, options: 3, rows: 1, size: "m", multiple: false)
    options = (1..options).map { |i| ["Option #{i}", i] }
    options.unshift(["", ""]) if include_blank
    options.map! { tag.option(_1, value: _2) }

    render component("ui/forms/input").new(
      tag: :select,
      "size" => rows > 1 ? rows : nil,
      error: error ? "There is an error" : nil,
      size: size.to_sym,
      multiple: multiple,
    ).with_content(options.reduce(:+))
  end

  # @param error toggle
  # @param size select { choices: [s, m, l] }
  # @param content textarea
  def textarea_playground(error: false, size: "m", content: "value")
    render component("ui/forms/input").new(
      tag: :textarea,
      size: size.to_sym,
      error: error ? "There is an error" : nil,
    ).with_content(content)
  end

  private

  def input_types
    current_component::TYPES.to_a
  end
end
