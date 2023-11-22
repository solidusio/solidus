# frozen_string_literal: true

# @component "ui/dropdown"
class SolidusAdmin::UI::Dropdown::ComponentPreview < ViewComponent::Preview
  include SolidusAdmin::Preview

  def overview
    render_with_template
  end

  # @param text text
  # @param size select { choices: [s, m] }
  # @param direction select { choices: [left, right] }
  # @param open toggle
  def playground(text: "text", size: :m, direction: :right, open: false)
    render component("ui/dropdown").new(
      text: text,
      size: size.to_sym,
      direction: direction.to_sym,
      style: "float: #{direction == :left ? 'right' : 'left'}",
      open: open,
    ).with_content(
      tag.span("Lorem ipsum dolor sit amet"),
    )
  end
end
